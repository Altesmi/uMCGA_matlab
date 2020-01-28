%Script to call uMCGA and fit FallingSphere model to testData.mat
%The goal is to find an optimal drag coefficient Cd. All other parameters
%are correct

addpath('~/uMCGA/'); %add umcga.m to path
%load('testData.mat');
%set uMCGA parameters

problem = struct;
problem.populationSize = 200;
problem.populationSizeExtra = 400;
problem.NElite = 10;
problem.Ngen = 30;
problem.Nrun = 10;
problem.Ndataset = 1;
problem.mutationProbability = 0.3;
problem.parallel = 0;
problem.models.model1 = 'fallingsphere';
problem.data.data1 = testData;

problem.params.set1.startingHeight = 100;
problem.params.set1.press = 101325;
problem.params.set1.mediumMolarMass = 0.29;
problem.params.set1.temperature = 298;
problem.params.set1.Cd = 1; %init
problem.params.set1.radius = 0.1;
problem.params.set1.mass = 1;
problem.params.set1.tstart = 1e-3;
problem.params.set1.tend = 10;

problem.gofFunction = 'gof';
problem.badFitness = 1e5;

problem.fitparams.Cd = struct;
problem.fitparams.Cd.min = 0;
problem.fitparams.Cd.max = 10;
problem.fitparams.Cd.log = 0;
problem.fitparams.Cd.normalize = 0;


res = umcga(problem);
