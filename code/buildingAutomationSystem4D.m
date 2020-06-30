%% Building automation system verification: Case 1
%
% Convex chance-constraint+open-loop-based underapproximation to construct the
% stochastic reach set for building automation system (Case 1) at prob_thresh = 0.8
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
% Step 1: Do the 2D computation
set_of_dir_vecs = spreadPointsOnUnitSphere(2, cco_n_dir_vecs, verbose_spread);
set_of_dir_vecs = [set_of_dir_vecs; zeros(2, cco_n_dir_vecs)];

%% Construction of the chance-open-based underapproximation
fprintf('Convex chance-constrained approach for alpha=%1.2f\n', prob_thresh);
timerVal = tic;
% SReachSet options preparation
% Step 2: Do 2D computation
init_safe_set_affine = Polyhedron('He', ...
    [zeros(2,2) eye(2,2) slice_at_x3_and_x4_init]);
cco_options = SReachSetOptions('term', 'chance-open', ...
    'set_of_dir_vecs', set_of_dir_vecs, 'verbose', 0, ...
    'init_safe_set_affine', init_safe_set_affine, ...
    'compute_style', 'cheby');

% Perform the set computation
[underapprox_stoch_reach_polytope_cco, extra_info_cco] = SReachSet('term', ...
    'chance-open', sys, prob_thresh, safety_tube, cco_options);
elapsed_time_cco = toc(timerVal);
underapprox_stoch_reach_polytope_cco_2D = ...
    underapprox_stoch_reach_polytope_cco.slice([3,4], slice_at_x3_and_x4_init);

%% Plot the figures
figure(1);
clf
plot(safe_set_2D,'color','y');
hold on;
plot(underapprox_stoch_reach_polytope_cco_2D, 'color','m');
box on;
grid on;
axis tight;axis equal;
xlabel('$x_1$','interpreter','latex');
ylabel('$x_2$','interpreter','latex');
leg=legend({'Safe set','Underapproximative polytope'});
set(leg,'Location','bestoutside');
title('Underapprox. stochastic reach-avoid set (BAS)');
saveas(gcf, '../results/BAS_StochasticViabilitySet.png');

%% Disp
fprintf('Time taken for the reach set computation: %1.2f\n', ...
    elapsed_time_cco);
ratio_volume=underapprox_stoch_reach_polytope_cco_2D.volume/safe_set_2D.volume;
fprintf('Ratio of volume (2D): %1.2f\n', ratio_volume)
max_reach_prob = extra_info_cco(1).xmax_reach_prob;
fprintf('Lower bound on the maximum reach probability: %1.2f\n', max_reach_prob)
save('../results/buildingAutomationSystem4D.mat');
