%% clean up

clear variables
clc
close all
%% My test run

% Set up the standard TXTL tubes
tube1 = txtl_extract('e1');
tube2 = txtl_buffer('b1');

% Set up a tube that will contain our DNA
tube3 = txtl_newtube('circuit_notetR');
txtl_adddna(tube3, ...
    'p70(50)', 'rbs(20)', 'sigma28(600)', 3, 'linear');
txtl_adddna(tube3, ...
    'p28_ptet(150)', 'rbs(20)', 'deGFP(1000)-lva-terminator', 3, 'linear');
txtl_adddna(tube3, ...
'p70(50)', 'rbs(20)', 'gamS(1000)', 1, 'plasmid');


tube4 = txtl_newtube('circuit_with_tetR');
txtl_adddna(tube4, ...
    'p70(50)', 'rbs(20)', 'tetR(600)', 3, 'linear');
txtl_adddna(tube4, ...
    'p70(50)', 'rbs(20)', 'sigma28(600)', 3, 'linear');
txtl_adddna(tube4, ...
    'p28_ptet(150)', 'rbs(20)', 'deGFP(1000)-lva-terminator', 3, 'linear');
txtl_adddna(tube4, ...
'p70(50)', 'rbs(20)', 'gamS(1000)', 1, 'plasmid');


% Mix the contents of the individual tubes
well_a1 = txtl_combine([tube1, tube2, tube3], [10, 8, 1]);
protein = well_a1.Species(findspecies(well_a1,'protein deGFP-lva-terminator*'));
protein.UserData = 500 / 3;
degradationRate = [2 0.01 1]; % !TODO: Find a reasonable value
Rlist = txtl_protein_degradation(well_a1, protein,degradationRate);

txtl_setup_parameters(well_a1);

% set up well_b1
well_b1 = txtl_combine([tube1, tube2, tube4], [10, 8, 1]);
protein_b = well_b1.Species(findspecies(well_b1,'protein deGFP-lva-terminator*'));
protein_b.UserData = 500 / 3;
Rlist = txtl_protein_degradation(well_b1, protein_b,degradationRate);

txtl_setup_parameters(well_b1);


 
%% Run a simulation
configsetObj = getconfigset(well_a1, 'active');
simulationTime = 10*60*60;
set(configsetObj, 'SolverType', 'ode23s');
set(configsetObj, 'StopTime', simulationTime);

% 1st run
[x_ode,t_ode] = txtl_runsim(well_a1,configsetObj,[],[]);


configsetObj_b1 = getconfigset(well_b1, 'active');

set(configsetObj_b1, 'SolverType', 'ode23s');
set(configsetObj_b1, 'StopTime', simulationTime);


[x_ode_b1,t_ode_b1] = txtl_runsim(well_b1,configsetObj_b1,[],[]);


%% plot the result

% DNA and mRNA plot
dataGroups{1,1} = 'DNA and mRNA';
dataGroups{1,2} = {'#(^DNA (\w+[-=]*)*)'};
%dataGroups{1,2} = {'DNA p70--rbs--sigma28'};
dataGroups{1,3} = {'b-','r-','b--','r--','y-','c-','g-','g--'};

% Gene Expression Plot
dataGroups{2,1} = 'Gene Expression';
dataGroups{2,2} = {'protein deGFP-lva-terminator*'}%,'protein tetRtetramer'};
%dataGroups{2,3} = {'b-','g--','g-','r-','b--','b-.'};

% Resource Plot
dataGroups{3,1} = 'Resource usage';

txtl_plot(t_ode,x_ode,well_a1,dataGroups);

txtl_plot(t_ode_b1,x_ode_b1,well_b1,dataGroups);

figure(3)
hold on
plot(t_ode/60,x_ode(:,findspecies(well_a1,'protein deGFP-lva-terminator*')),'b')
plot(t_ode_b1/60,x_ode_b1(:,findspecies(well_b1,'protein deGFP-lva-terminator*')),'r')
xlabel('Time [min]');
ylabel('Concentration [nM]');
hold off
legend('deGFP_no_tetR','deGFP_tetR')

