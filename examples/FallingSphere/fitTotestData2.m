%Script to call uMCGA and fit FallingSphere model to testData2.mat
%The goal is to find an optimal drag coefficient Cd and starting height. All other parameters
%are correct

addpath('~/uMCGA_matlab/'); %add folder where umcga.m is to path
load('testData.mat');
%set uMCGA parameters

problem = struct;
problem.populationSize = 400;
problem.populationSizeExtra = (400-20)*19;
problem.NElite = 20;
problem.Ngen = 20;
problem.Nrun = 1;
problem.Ndataset = 2;
problem.mutationProbability = 0.2;
problem.parallel = 0;

problem.models.model1 = 'fallingsphere';
problem.models.model2 = 'fallingsphere';

problem.data.data1 = testData;
problem.data.data2 = testData2;

problem.penaltyFunction = 'penalty2';

problem.params.set1.startingHeight = 100; %init
problem.params.set1.press = 101325;
problem.params.set1.mediumMolarMass = 0.29;
problem.params.set1.temperature = 298;
problem.params.set1.Cd = 0.1; %init
problem.params.set1.radius = 0.1; 
problem.params.set1.mass = 1;
problem.params.set1.tstart = 1e-3;
problem.params.set1.tend = 10;
problem.params.set1.includeToPenaltyFunction = {'mass'};

problem.params.set2.startingHeight = 1000;  %init
problem.params.set2.press = 101325;
problem.params.set2.mediumMolarMass = 0.29;
problem.params.set2.temperature = 298;
problem.params.set2.Cd = 1; %init
problem.params.set2.radius = 0.1;
problem.params.set2.mass = 0.1;
problem.params.set2.tstart = 1e-3;
problem.params.set2.tend = 30;

problem.gofFunction = 'gof2';
problem.badFitness = 1e5;

problem.fitparams.Cd = struct;
problem.fitparams.Cd.min = 0;
problem.fitparams.Cd.max = 5;
problem.fitparams.Cd.log = 0;
problem.fitparams.Cd.normalize = 0;

problem.fitparams.startingHeight = struct;
problem.fitparams.startingHeight.min = 1;
problem.fitparams.startingHeight.max = 1e4;
problem.fitparams.startingHeight.log = 1;
problem.fitparams.startingHeight.normalize = 0;


res = umcga(problem);

%% use analysis tools to plot the results

addpath('../../analysis');

plotuMCGAEstimatesAndFit(res,{'Cd','startingHeight'});

%fetch all Cd estimates from res

Cd = getuMCGAEstimate(res,'Cd');
