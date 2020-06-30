root_folder = presolve_setup;
diary(strcat(root_folder, 'console.txt'));
diary on;

clc;close all;

% Benchmark 1: Anesthesia delivery system
clearvars;srtinit;root_folder = presolve_setup;
automatedAnesthesiaDelivery3D

% Benchmark 2: Building automation system (4D case)
clearvars;srtinit;root_folder = presolve_setup;
buildingAutomationSystem4D

% Benchmark 2: Building automation system (7D case)
clearvars;srtinit;root_folder = presolve_setup;
buildingAutomationSystem7D

% Benchmark 3: Chain of integrators (n=2,3,4,5,6,7,10,20,40,100)
% To save runtime, cases for n in {10, 20, 40, 100} have been commented
clearvars;srtinit;root_folder = presolve_setup;
n_intg = 2;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;srtinit;root_folder = presolve_setup;
n_intg = 3;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;srtinit;root_folder = presolve_setup;
n_intg = 4;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;srtinit;root_folder = presolve_setup;
n_intg = 5;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;srtinit;root_folder = presolve_setup;
n_intg = 6;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;srtinit;root_folder = presolve_setup;
n_intg = 7;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

% Uncomment the following lines for running n in {10, 20, 40, 100} cases
% clearvars;srtinit;root_folder = presolve_setup;
% n_intg = 10;
% cco_compute_style = 'cheby';
% cco_verbose = 0;
% chainOfIntegrators;

% clearvars;srtinit;root_folder = presolve_setup;
% n_intg = 20;
% cco_compute_style = 'cheby';
% cco_verbose = 1;
% chainOfIntegrators;
% 
% clearvars;srtinit;root_folder = presolve_setup;
% n_intg = 40;
% cco_compute_style = 'cheby';
% cco_verbose = 1;
% chainOfIntegrators;
% 
% clearvars;srtinit;root_folder = presolve_setup;
% n_intg = 100;
% cco_compute_style = 'cheby';
% cco_verbose = 1;
% chainOfIntegrators;

clearvars;root_folder = presolve_setup;
parseMatfilesResults;

diary off;
