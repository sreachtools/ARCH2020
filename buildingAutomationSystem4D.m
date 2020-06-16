%% Building automation system verification: Case 1
% See ARCH 2019
%
% Comparison of (chance-constraint+open-loop)-based underapproximation with
% Lagrangian (set-theoretic)-based underapproximation to construct the
% stochastic reach set at prob_thresh = 0.8
%
% In the interest of time, Genzps+patternsearch-based underapproximation has
% been disabled. See should_we_run_genzps

clearvars;close all;srtinit;
fprintf('\n\nbuildingAutomationSystem Case 1: 4D\n');

%% Problem setup
% System matrices
state_matrix = ...
   [ 0.6682   , 0       , 0.02632   ,        0;
     0        , 0.6830  ,       0   ,  0.02096;
    1.0005    , 0       ,  -0.000499,      0;
    0         , 0.8004  ,       0   , 0.1996];
input_matrix = [0.1320;0.1402;0;0];
dist_matrix = eye(4);

% Input space
input_space = Polyhedron('lb',15,'ub',22);

% Disturbance definition --- Combine Q + \Sigma W as a single Gaussian
% random vector of mean Q and covariance matrix \Sigma^T \Sigma
dist_mu = [3.3378;2.9272;13.0207;10.4166];
dist_sigma = diag([0.0774,0.0774,0.3872,0.3098]).^2;
dist_rv = RandomVector.gaussian(dist_mu, dist_sigma);

% System definition
sys = LtiSystem('StateMatrix',state_matrix, 'InputMatrix',input_matrix, ...
    'DisturbanceMatrix',dist_matrix, 'InputSpace', input_space, ...
    'Disturbance', dist_rv);

% Time steps
time_horizon = 6;

% Safety specification --- Constraints are present only the first two states
safe_set = Polyhedron('lb', 19.5 * [1,1,-Inf,-Inf], 'ub', 20.5 * [1,1,Inf,Inf]);
safety_tube = Tube('viability', safe_set, time_horizon);

% Create a slice
x3_init=20;
x4_init=20;
slice_at_x3_and_x4_init = [x3_init; x4_init];      
safe_set_2D = safe_set.slice([3,4], slice_at_x3_and_x4_init);

% Stochastic viability threshold: Compute the set of initial states which
% have the probability of safety above this threshold
prob_thresh = 0.8;

% How many directions to explore for chance-open and genzps
cco_n_dir_vecs = 8;
verbose_spread = 0;
% % Step 1: Do the 4D computation
% set_of_dir_vecs = spreadPointsOnUnitSphere(sys.state_dim, cco_n_dir_vecs, 
%     verbose_spread);
% save('set_of_dir_vecs_building_automation_case1.mat', 'set_of_dir_vecs');
% load('set_of_dir_vecs_building_automation_case1.mat', 'set_of_dir_vecs');
% % Step 1: Do the 2D computation
set_of_dir_vecs = spreadPointsOnUnitSphere(2, cco_n_dir_vecs, verbose_spread);
set_of_dir_vecs = [set_of_dir_vecs; zeros(2, cco_n_dir_vecs)];

%% Construction of the chance-open-based underapproximation
disp('>>> Chance-constraint-based underapproximation');
timerVal = tic;
% SReachSet options preparation
% Step 2: Do 4D computation
% cco_options = SReachSetOptions('term', 'chance-open', ...
%     'set_of_dir_vecs', set_of_dir_vecs, 'verbose', 0, ...
%     'compute_style', 'cheby');
% Step 2: Do 2D computation
init_safe_set_affine = Polyhedron('He', ...
    [zeros(2,2) eye(2,2) slice_at_x3_and_x4_init]);
cco_options = SReachSetOptions('term', 'chance-open', ...
    'set_of_dir_vecs', set_of_dir_vecs, 'verbose', 0, ...
    'init_safe_set_affine', init_safe_set_affine, ...
    'compute_style', 'cheby');

% Perform the set computation
[cco_stoch_viab_set, cco_extra_info] = SReachSet('term','chance-open', sys, ...
    prob_thresh, safety_tube, cco_options);
elapsed_time_cc = toc(timerVal);
cco_stoch_viab_set_2D = cco_stoch_viab_set.slice([3,4], ...
    slice_at_x3_and_x4_init);

% %% Construction of the lagrangian-based underapproximation
% fprintf('\n\n\n >>> Lagrangian-based underapproximation\n');
% timerVal = tic;
% lag_options = SReachSetOptions('term', 'lag-under', 'bound_set_method', ...
%     'ellipsoid', 'compute_style', 'vfmethod', 'verbose', 2, ...
%     'vf_enum_method', 'lrs');
% lag_stoch_viab_set = SReachSet('term','lag-under',sys, prob_thresh, ...
%     safety_tube, lag_options);
% elapsed_time_lag = toc(timerVal);
% lag_stoch_viab_set_2D = lag_stoch_viab_set.slice([3,4], ...
%     slice_at_x3_and_x4_init);

% %% Construction of the Genz+patternsearch-based underapproximation
% fprintf('\n\n\n >>> Genz+patternsearch-based underapproximation\n');
% timerVal = tic;
% % Directions to explore
% theta_vec = linspace(0, 2*pi, genzps_n_dir_vecs + 1);
% theta_vec = theta_vec(1:end-1);
% set_of_dir_vecs = [cos(theta_vec);sin(theta_vec);
%                    zeros(2,genzps_n_dir_vecs)];
% % Slice of the stochastic viability set of interest
% init_safe_set_affine = Polyhedron('He',[0,0,1,0,x3_init;0,0,0,1,x4_init]);
% % SReachSet options preparation
% genzps_options = SReachSetOptions('term', 'genzps-open', ...
%     'init_safe_set_affine', init_safe_set_affine, 'set_of_dir_vecs', ...
%     set_of_dir_vecs,'verbose',1);
% genzps_stoch_viab_set = SReachSet('term','genzps-open',sys, prob_thresh, ...
%     safety_tube, genzps_options);
% elapsed_time_genzps = toc(timerVal);

% %% Plot the figures
% figure(1);
% clf
% plot(safe_set_2D,'color','y');
% hold on;
% plot(cco_stoch_viab_set_2D, 'color','m');
% box on;
% grid on;
% axis tight;axis equal;
% xlabel('$x_1$','interpreter','latex');
% ylabel('$x_2$','interpreter','latex');
% % In general, increase the fontsize
% set(gca,'FontSize',20);
% % % If code ocean, save the results
% % saveas(gcf, '../results/BAS_StochasticViabilitySet.png');

%% Disp
fprintf('\n\nLower bound on reach-avoid probability (chance-open): %1.6f\n',...
    max(cco_extra_info(1).xmax_reach_prob))
fprintf('Time taken for the reach set computation (chance-open): %1.2f\n', ...
    elapsed_time_cc)
ratio_volume_2D = cco_stoch_viab_set_2D.volume/safe_set_2D.volume;
fprintf('Ratio of 2D volume: %1.2f\n', ratio_volume_2D)
%     fprintf('Time taken for the reach set computation (genzps-open): %1.2f\n', elapsed_time_genzps)
%     fprintf('Time taken for the reach set computation (lag-under): %1.2f\n', elapsed_time_lag)
save('matfiles/results/buildingAutomationSystem4D.mat');