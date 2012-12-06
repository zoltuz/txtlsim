% repressilator.m - repressilator example
% R. M. Murray, 8 Sep 2012
%
% This file contains a simple example of setting up a TXTL simulation
% for a negatively autoregulated gene.  The constants for this example
% come from the Simbiology toolbox example page:
%
%    http://www.mathworks.com/help/toolbox/simbio/gs/fp58748.html
%

% Set up the standard TXTL tubes
% These load up the RNAP, Ribosome and degradation enzyme concentrations
tube1 = txtl_extract('c1');
tube2 = txtl_buffer('e1');

% Now set up a tube that will contain our DNA
tube3 = txtl_newtube('circuit');



% Define the DNA strands (defines TX-TL species + reactions)
dna_tetR = txtl_adddna(tube3, 'thio-junk(500)-placI(50)', 'rbs(20)', 'tetR(647)-lva(40)-terminator(100)', 5, 'linear');%
dna_lacI = txtl_adddna(tube3, 'thio-junk(500)-plambda(50)', 'rbs(20)', 'lacI(647)-lva(40)-terminator(100)', 5, 'linear');%
dna_lambda = txtl_adddna(tube3, 'thio-junk(500)-ptet(50)', 'rbs(20)', 'lambda(647)-lva(40)-terminator(100)', 5, 'linear');%
dna_deGFP = txtl_adddna(tube3, 'p70(50)', 'rbs(20)', 'deGFP(1000)', 5, 'linear');
dna_gamS = txtl_adddna(tube3, 'p70(50)', 'rbs(20)', 'gamS(1000)', 1, 'plasmid');


%
% Next we have to set up the reactions that describe how the circuit
% works.  Transcription and translation are already included above, so
% we just need to include protein-protein and protein-DNA interactions.
%
% Note that the commands in this section are standard Simbiology commands,
% so you can put anything you want here.
%

% No additional reactions required for this circuit
% tetR-DNA interactions are automatically included in tetR setup

%
% Describe the actual experiment that we want to run.  This includes 
% combining the various tubes and also adding any additional inducers
% or purified proteins that you want to include in the run.
%

% Mix the contents of the individual tubes
Mobj = txtl_combine([tube1, tube2, tube3], [6, 1, 1.5]);

%
% Run a simulaton
%
% At this point, the entire experiment is set up and loaded into 'Mobj'.
% So now we just use standard Simbiology and MATLAB commands to run
% and plot our results!
%

% Run a simulation
configsetObj = getconfigset(Mobj, 'active');
set(configsetObj, 'StopTime', 5*60*60)
if ~strcmp(version('-release'),'2012a')
 set(configsetObj, 'SolverType', 'ode23s');
end

[t_ode, x_ode, mObj, simData] = txtl_runsim(Mobj, configsetObj,[], []);
names = simData.DataNames;

[t_ode1, x_ode1, mObj, simData] = txtl_runsim(Mobj, configsetObj,t_ode, x_ode);


% Top row: protein and RNA levels
figure(1); clf(); subplot(2,1,1);
iTetR = findspecies(Mobj, 'protein tetR-lva-terminator');
ilacI = findspecies(Mobj, 'protein lacI-lva-terminator');
ilambda = findspecies(Mobj, 'protein lambda-lva-terminator');
iGamS = findspecies(Mobj, 'protein gamS');
iGFP = findspecies(Mobj, 'protein deGFP');
iGFPs = findspecies(Mobj, 'protein deGFP*');
p = plot(t_ode/60, x_ode(:, iTetR), 'b-', t_ode/60, x_ode(:, ilacI), 'r-', ...
    t_ode/60, x_ode(:, ilambda), 'k-', t_ode/60, x_ode(:, iGamS), 'c-', ...
  t_ode/60, x_ode(:, iGFP) + x_ode(:, iGFPs), 'g--', ...
  t_ode/60, x_ode(:, iGFPs), 'g-');

title('Negative Autoregulation Example - Gene Expression');
lgh = legend({'TetR','lacI', 'lambda', 'GamS', 'GFPt', 'GFP*'}, 'Location', 'NortheastOutside');
legend(lgh, 'boxoff');
ylabel('Species amounts [nM]');
xlabel('Time [min]');

% Second row, left: resource limits
subplot(2,2,3);
iNTP = findspecies(Mobj, 'NTP');
iAA  = findspecies(Mobj, 'AA');
iRNAP  = findspecies(Mobj, 'RNAP70');
iRibo  = findspecies(Mobj, 'Ribo');
mMperunit = 100 / 1000;			% convert from NTP, AA units to mM
p = plot(...
  t_ode/60, x_ode(:, iAA)/x_ode(1, iAA), 'b-', ...
  t_ode/60, x_ode(:, iNTP)/x_ode(1, iNTP), 'r-', ...
  t_ode/60, x_ode(:, iRNAP)/max(x_ode(:, iRNAP)), 'r--', ...
  t_ode/60, x_ode(:, iRibo)/x_ode(1, iRibo), 'b--');

title('Resource usage');
lgh = legend(...
  {'AA [mM]', 'NTP [mM]', 'RNAP70 [nM]', 'Ribo [nM]'}, ...
  'Location', 'Northeast');
legend(lgh, 'boxoff');
ylabel('Species amounts [normalized]');
xlabel('Time [min]');
% Second row, right: DNA and mRNA
subplot(2,2,4);
iDNA_tetR = findspecies(Mobj, 'DNA thio-junk-placI--rbs--tetR-lva-terminator');%
iDNA_lacI = findspecies(Mobj, 'DNA thio-junk-plambda--rbs--lacI-lva-terminator');
iDNA_lambda = findspecies(Mobj, 'DNA thio-junk-ptet--rbs--lambda-lva-terminator');
iDNA_gamS = findspecies(Mobj, 'DNA p70--rbs--gamS');
iRNA_tetR = findspecies(Mobj, 'RNA rbs--tetR-lva-terminator');
iRNA_gamS = findspecies(Mobj, 'RNA rbs--gamS');
p = plot(t_ode/60, x_ode(:, iDNA_tetR), 'b-', ...
  t_ode/60, x_ode(:, iDNA_gamS), 'r-', ...
  t_ode/60, x_ode(:, iRNA_tetR), 'b--', ...
  t_ode/60, x_ode(:, iRNA_gamS), 'r--');

title('DNA and mRNA');
lgh = legend(...
  names([iDNA_tetR, iDNA_gamS, iRNA_tetR, iRNA_gamS]), ...
  'Location', 'Northeast');
legend(lgh, 'boxoff');
ylabel('Species amounts [nM]');
xlabel('Time [min]');


% Automatically use MATLAB mode in Emacs (keep at end of file)
% Local variables:
% mode: matlab
% End:
