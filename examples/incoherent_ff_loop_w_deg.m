%% clean up

clear variables
clc
close all
%% My test run

% Set up the standard TXTL tubes
tube1 = txtl_extract('E7');
tube2 = txtl_buffer('E7');

% Set up a tube that will contain our DNA
tube3 = txtl_newtube('circuit_open_loop');
txtl_add_dna(tube3, ...
    'p70(50)', 'rbs(20)', 'sigma28(600)', 0.2, 'plasmid');
txtl_add_dna(tube3, ...
    'p28_ptet(150)', 'rbs(20)', 'deGFP-lva(1000)', 3, 'plasmid');
dna_clpx = txtl_add_dna(tube3, ...
    'p70(50)', 'rbs(20)', 'ClpX(1269)', ...	% promoter, rbs, gene
    1, ...					% concentration (nM)
    'plasmid');					% type



tube4 = txtl_newtube('circuit_closed_loop');
txtl_add_dna(tube4, ...
    'p28(50)', 'rbs(20)', 'tetR(600)', 0.01, 'plasmid');
txtl_add_dna(tube4, ...
    'p70(50)', 'rbs(20)', 'sigma28(600)',0.2, 'plasmid');
txtl_add_dna(tube4,'p28_ptet(150)', 'rbs(20)', 'deGFP-lva(1000)',3, 'plasmid');
dna_clpx = txtl_add_dna(tube4, ...
    'p70(50)', 'rbs(20)', 'ClpX(1269)', ...	% promoter, rbs, gene
    1, ...					% concentration (nM)
    'plasmid');					% type

% txtl_add_dna(tube3, ...
%     'p70(50)', 'rbs(20)', 'ClpX(1269)', 1, 'plasmid');




% Mix the contents of the individual tubes
well_a1 = txtl_combine([tube1, tube2, tube3]);





% set up well_b1
well_b1 = txtl_combine([tube1, tube2, tube4]);



txtl_addspecies(well_b1,'protein ClpX*',5);
txtl_addspecies(well_b1,'protein ClpP*',1);


txtl_addspecies(well_a1,'protein ClpX*',5);
txtl_addspecies(well_a1,'protein ClpP*',1);




%% Run a simulation

simulationTime = 12*60*60;


% % 1st run
[t_ode,x_ode] = txtl_runsim(well_a1,simulationTime);



[t_ode_b1,x_ode_b1] = txtl_runsim(well_b1,simulationTime);


%% plot the result
close all
% DNA and mRNA plot
dataGroups{1,1} = 'DNA and mRNA';
dataGroups{1,2} = {'ALL_DNA'};
dataGroups{1,3} = {'b-','r-','g--','k--','y-','c-','g-','g--'};

% Gene Expression Plot
dataGroups{2,1} = 'Gene Expression';
dataGroups{2,2} = {'protein deGFP-lva*','protein tetRdimer'};
%dataGroups{2,3} = {'b-','g--','g-','r-','b--','b-.'};

% Resource Plot
dataGroups{3,1} = 'Resource usage';
%
txtl_plot(t_ode,x_ode,well_a1,dataGroups);

txtl_plot(t_ode_b1,x_ode_b1,well_b1,dataGroups);

%%
% figure(3)
% hold on
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'protein tetR')),'b')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'protein deGFP*')),'g')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'protein tetRdimer')),'r')
% xlabel('Time [min]');
% ylabel('Concentration [nM]');
% hold off
% legend('tetR','deGFP*','tetRdimer')

% figure(4)
% hold on
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'RNAP28:DNA p28_ptet--rbs--deGFP-lva')),'b')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'DNA p28_ptet--rbs--deGFP-lva:protein tetRdimer')),'r')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'RNAP28:DNA p28_ptet--rbs--deGFP-lva:protein tetRdimer')),'g')
% xlabel('Time [min]');
% ylabel('Concentration [nM]');
% hold off
% legend('DNA:RNAP28','DNA:tetR','DNA:RNAP28:tetR','Location','Best')
%
%
% figure(5)
% hold on
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'RNAP')),'b')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'RNAP28')),'r')
% plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'RNAP70')),'g')
% xlabel('Time [min]');
% ylabel('Concentration [nM]');
% hold off
% legend('RNAP','RNAP28','RNAP70')
%
%
figure(6)
hold on
plot(t_ode/60,x_ode(:,findspecies(well_a1,'protein deGFP-lva*')),'b')
plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'protein deGFP-lva*')),'r')

xlabel('Time [min]');
ylabel('Concentration [nM]');
hold off
legend('no repression - deGFP*','repression w/ tetR - deGFP*','Location','Best')


figure(7)
plot(t_ode_b1/60,x_ode_b1(:,[40 46 47 38 39]))
legend('deGFP:ClpX','unfolded deGFP','unfolded deGFP:ClpP','ClpX','ClpP')


figure(8)
plot(t_ode/60,x_ode(:,[32 37 38 30 31]))
legend('deGFP:ClpX','unfolded deGFP','unfolded deGFP:ClpP','ClpX','ClpP')

figure(9)
hold on
plot(t_ode_b1/60,x_ode_b1(:,[48]),'r')
plot(t_ode/60,x_ode(:,[39]),'b')
xlabel('Time [min]');
ylabel('Degraded deGFP*');
legend('repression','no repression','Location','SouthEast')
hold off

figure(10)
hold on
plot(t_ode_b1/60,x_ode_b1(:,[46]),'r')
plot(t_ode/60,x_ode(:,[37]),'b')
xlabel('Time [min]');
ylabel('Unfolded deGFP*');
legend('repression','no repression','Location','SouthEast')
hold off


