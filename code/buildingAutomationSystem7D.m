%% Building automation system verification: Case 2
%
% Convex chance-constraint+open-loop-based underapproximation to construct the
% stochastic reach set for building automation system (Case 2) at prob_thresh = 0.8

fprintf('\n\nbuildingAutomationSystem Case 2: 7D\n');

%% Problem setup
% System matrices
load('/data/case2_bas.mat')
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
fprintf('Convex chance-constrained approach for alpha=%1.2f\n', prob_thresh);
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
[underapprox_stoch_reach_polytope_cco, extra_info_cco] = SReachSet('term', ...
    'chance-open',sys, prob_thresh, safety_tube, cco_options);
elapsed_time_cco = toc(timerVal);

% Construct the 1D set
if ~underapprox_stoch_reach_polytope_cco.isEmptySet()
    underapprox_stoch_reach_polytope_cco_1D = ...
        underapprox_stoch_reach_polytope_cco.slice(2:7, ...
            [x2_init;x3_init;x4_init;x5_init;x6_init;x7_init]);
else
    underapprox_stoch_reach_polytope_cco_1D = Polyhedron(1);
end

%% Disp
fprintf('Time taken for the reach set computation: %1.2f\n', ...
    elapsed_time_cco);
ratio_volume = abs(diff(underapprox_stoch_reach_polytope_cco_1D.V)) ...
    / abs(diff(safe_set.V(:, 1)));
fprintf('Ratio of volume (1D): %1.2f\n', ratio_volume)
max_reach_prob = extra_info_cco(1).xmax_reach_prob;
fprintf('Lower bound on the maximum reach probability: %1.2f\n', max_reach_prob)
save('../results/buildingAutomationSystem7D.mat');
