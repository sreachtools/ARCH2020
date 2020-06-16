clc;
diary('matfiles/console.txt');
diary on;
clearvars;close all;srtinit;fixgurobipath;
automatedAnesthesiaDelivery3D
clearvars;close all;srtinit;fixgurobipath;
buildingAutomationSystem4D
clearvars;close all;srtinit;fixgurobipath;
buildingAutomationSystem7D

clearvars;close all;srtinit;fixgurobipath;
n_intg = 2;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 3;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 4;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 5;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 6;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 7;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 10;
cco_compute_style = 'cheby';
cco_verbose = 0;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 20;
cco_compute_style = 'cheby';
cco_verbose = 1;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 40;
cco_compute_style = 'cheby';
cco_verbose = 1;
chainOfIntegrators;

clearvars;close all;srtinit;fixgurobipath;
n_intg = 100;
cco_compute_style = 'cheby';
cco_verbose = 1;
chainOfIntegrators;
diary off;