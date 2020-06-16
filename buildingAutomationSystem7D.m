%% Building automation system verification: Case 2
% See ARCH 2019
%
% Comparison of (chance-constraint+open-loop)-based underapproximation with
% Lagrangian (set-theoretic)-based underapproximation to construct the
% stochastic reach set at prob_thresh = 0.8
%
% In the interest of time, Genzps+patternsearch-based underapproximation has
% been disabled. See should_we_run_genzps
fprintf('\n\nbuildingAutomationSystem Case 2: 7D\n');

%% Problem setup
% System matrices
load('matfiles/case2_bas.mat')
state_matrix = Ahat7;
input_matrix = Bhat7;
dist_matrix = Fhat7;

% Input space
input_space = Polyhedron('lb',15,'ub',22);

% Disturbance definition
dist_mu = zeros(6,1);
dist_sigma = Sigma^2;
dist_rv = RandomVector.gaussian(dist_mu, dist_sigma);

% System definition
sys = LtiSystem('StateMatrix',state_matrix, 'InputMatrix',input_matrix, ...
    'DisturbanceMatrix',dist_matrix, 'InputSpace', input_space, ...
    'Disturbance', dist_rv);

% Time steps
time_horizon = 6;

% Safety specification --- Constraints are present only the first two states
safe_set = Polyhedron('lb', [19.5;-Inf*ones(6,1)], 'ub', [20.5;Inf*ones(6,1)]);
safety_tube = Tube('viability', safe_set, time_horizon);

% Stochastic viability threshold: Compute the set of initial states which
% have the probability of safety above this threshold
prob_thresh = 0.8;
% Slice of the stochastic viability set of interest
x2_init = 20;
x3_init = 20;
x4_init = 20;
x5_init = 20;
x6_init = 20;
x7_init = 20;

%% Construction of the chance-open-based underapproximation
disp('>>> Chance-constraint-based underapproximation');
timerVal = tic;
% Directions to explore
set_of_dir_vecs = [-1,1;
                   zeros(6,2)];
% Slice of the stochastic viability set of interest
init_safe_set_affine = Polyhedron('He',[zeros(6,1),eye(6),[x2_init;x3_init;x4_init;x5_init;x6_init;x7_init]]);
% SReachSet options preparation
cco_options = SReachSetOptions('term', 'chance-open', ...
    'init_safe_set_affine', init_safe_set_affine, 'set_of_dir_vecs', ...
    set_of_dir_vecs, 'verbose', 0, 'compute_style', 'cheby');
[cco_stoch_viab_set, extra_info] = SReachSet('term','chance-open',sys, ...
    prob_thresh, safety_tube, cco_options);
elapsed_time_cc = toc(timerVal);
% For plotting, construct the slice
if ~cco_stoch_viab_set.isEmptySet()
    cco_stoch_viab_set_1D =  cco_stoch_viab_set.slice(2:7, ...
        [x2_init;x3_init;x4_init;x5_init;x6_init;x7_init]);
else
    cco_stoch_viab_set_1D = Polyhedron(1);
end

% %% Construction of the lagrangian-based underapproximation
% fprintf('\n\n\n >>> Lagrangian-based underapproximation\n');
% timerVal = tic;
% lag_options = SReachSetOptions('term', 'lag-under', 'bound_set_method', ...
%     'ellipsoid', 'compute_style', 'vfmethod', 'verbose', 1);
% lag_stoch_viab_set = SReachSet('term','lag-under',sys, prob_thresh, ...
%     safety_tube, lag_options);
% elapsed_time_lag = toc(timerVal);
% % For plotting, construct the slice
% lag_stoch_viab_set_1D = lag_stoch_viab_set.slice(2:7, ...
%     [x2_init;x3_init;x4_init;x5_init;x6_init;x7_init]);

%% Disp
fprintf('\n\nLower bound on reach-avoid probability (chance-open): %1.6f\n', extra_info(1).xmax_reach_prob)
fprintf('Time taken for the reach set computation (chance-open): %1.2f\n', elapsed_time_cc)
ratio_volume_1D = abs(diff(cco_stoch_viab_set_1D.V))/abs(diff(safe_set.V(:, 1)));
fprintf('Ratio of volume: %1.2f\n', ratio_volume_1D)

% fprintf('Time taken for the reach set computation (lag-under): %1.2f\n', elapsed_time_lag)
% disp('Chance-const. set')
% disp('Lagrangian set')
% disp(lag_stoch_viab_set_1D.V)
% disp('Safe set')
% disp(safe_set.V(:,1))
save('matfiles/results/buildingAutomationSystem7D.mat');