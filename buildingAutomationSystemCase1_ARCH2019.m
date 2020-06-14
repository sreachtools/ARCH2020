%% Building automation system verification: Case 1
% See ARCH 2019
%
% Comparison of (chance-constraint+open-loop)-based underapproximation with
% Lagrangian (set-theoretic)-based underapproximation to construct the
% stochastic reach set at prob_thresh = 0.8
%
% In the interest of time, Genzps+patternsearch-based underapproximation has
% been disabled. See should_we_run_genzps

clear;clc;close all;srtinit;

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

% Disturbance definition
dist_mu = [3.4378;2.9272;13.0207;10.4166];
dist_sigma = diag([0.0774,0.0774,0.3872,0.3098]);
dist_rv = RandomVector.gaussian(dist_mu, dist_sigma);

% System definition
sys = LtiSystem('StateMatrix',state_matrix, 'InputMatrix',input_matrix, ...
    'DisturbanceMatrix',dist_matrix, 'InputSpace', input_space, ...
    'Disturbance', dist_rv);

% Time steps
time_horizon = 6;

% Safety specification --- Constraints are present only the first two states
safe_set = Polyhedron('lb', [-19.5;-19.5;-Inf;-Inf], 'ub', [20.5;20.5;Inf;Inf]);
safety_tube = Tube('viability', safe_set, time_horizon);

% Stochastic viability threshold: Compute the set of initial states which
% have the probability of safety above this threshold
prob_thresh = 0.8;
% Slice of the stochastic viability set of interest
x3_init = 20;
x4_init = 20;

% How many directions to explore for chance-open and genzps
cc_n_dir_vecs = 16;
genzps_n_dir_vecs = 16;
should_we_run_genzps = 0;   % It takes time for (slightly) better results

%% Construction of the chance-open-based underapproximation
disp('>>> Chance-constraint-based underapproximation');
timerVal = tic;
% Directions to explore
theta_vec = linspace(0, 2*pi, cc_n_dir_vecs + 1);
theta_vec = theta_vec(1:end-1);
set_of_dir_vecs = [cos(theta_vec);sin(theta_vec);zeros(2,cc_n_dir_vecs)];
% Slice of the stochastic viability set of interest
init_safe_set_affine = Polyhedron('He',[0,0,1,0,x3_init;0,0,0,1,x4_init]);
% SReachSet options preparation
cco_options = SReachSetOptions('term', 'chance-open', ...
    'init_safe_set_affine', init_safe_set_affine, 'set_of_dir_vecs', ...
    set_of_dir_vecs, 'verbose', 1);
[cco_stoch_viab_set, extra_info] = SReachSet('term','chance-open',sys, prob_thresh, ...
    safety_tube, cco_options);
elapsed_time_cc = toc(timerVal);
% For plotting, construct the slice
cco_stoch_viab_set_2D =  cco_stoch_viab_set.slice([3,4], [x3_init;x4_init]);

%% Construction of the lagrangian-based underapproximation
fprintf('\n\n\n >>> Lagrangian-based underapproximation\n');
timerVal = tic;
lag_options = SReachSetOptions('term', 'lag-under', 'bound_set_method', ...
    'ellipsoid', 'compute_style', 'vfmethod', 'verbose', 1);
lag_stoch_viab_set = SReachSet('term','lag-under',sys, prob_thresh, ...
    safety_tube, lag_options);
elapsed_time_lag = toc(timerVal);
% For plotting, construct the slice
lag_stoch_viab_set_2D = lag_stoch_viab_set.slice([3,4], [x3_init;x4_init]);

%% Construction of the Genz+patternsearch-based underapproximation
if should_we_run_genzps
    fprintf('\n\n\n >>> Genz+patternsearch-based underapproximation\n');
    timerVal = tic;
    % Directions to explore
    theta_vec = linspace(0, 2*pi, genzps_n_dir_vecs + 1);
    theta_vec = theta_vec(1:end-1);
    set_of_dir_vecs = [cos(theta_vec);sin(theta_vec);
                       zeros(2,genzps_n_dir_vecs)];
    % Slice of the stochastic viability set of interest
    init_safe_set_affine = Polyhedron('He',[0,0,1,0,x3_init;0,0,0,1,x4_init]);
    % SReachSet options preparation
    genzps_options = SReachSetOptions('term', 'genzps-open', ...
        'init_safe_set_affine', init_safe_set_affine, 'set_of_dir_vecs', ...
        set_of_dir_vecs,'verbose',1);
    genzps_stoch_viab_set = SReachSet('term','genzps-open',sys, prob_thresh, ...
        safety_tube, genzps_options);
    elapsed_time_genzps = toc(timerVal);
    % For plotting, construct the slice
    genzps_stoch_viab_set_2D =  genzps_stoch_viab_set.slice([3,4], ...
        [x3_init; x4_init]);
else
    fprintf('\n\n\n>>> Skipping genzps-based computation.\n');
end

%% Plot the figures
figure(1);
clf
plot(Polyhedron('V',safe_set.V(:,1:2)),'color','y');
hold on;
if should_we_run_genzps
    plot(genzps_stoch_viab_set_2D, 'color','g');
end
plot(cco_stoch_viab_set_2D, 'color','m');
plot(lag_stoch_viab_set_2D, 'color','b');
if should_we_run_genzps
    leg=legend('Safe set', 'Genz+patternsearch', ...
        'Chance-const.', ...
        'Lagrangian');
else
    leg=legend('Safe set', 'Chance-const.', 'Lagrangian');
end
set(leg,'Location','Best');
title(sprintf('Safety analysis for $x_3[0]=$%1.2f, $x_4[0]=$%1.2f', x3_init, ...
    x4_init), 'interpreter','latex');
box on;
grid on;
axis tight;axis equal;
xlabel('$x_1$','interpreter','latex');
ylabel('$x_2$','interpreter','latex');
% In general, increase the fontsize
set(gca,'FontSize',20);
% If code ocean, save the results
saveas(gcf, '../results/BAS_StochasticViabilitySet.png');

%% Disp
if should_we_run_genzps
    fprintf('\n\nLower bound on reach-avoid probability (chance-open): %1.6f\n', max(extra_info.xmax_reach_prob))
    fprintf('Time taken for the reach set computation (chance-open): %1.2f\n', elapsed_time_cc)
    fprintf('Time taken for the reach set computation (genzps-open): %1.2f\n', elapsed_time_genzps)
    fprintf('Time taken for the reach set computation (lag-under): %1.2f\n', elapsed_time_lag)
else
    fprintf('\n\nLower bound on reach-avoid probability (chance-open): %1.6f\n', max(extra_info.xmax_reach_prob))
    fprintf('Time taken for the reach set computation (chance-open): %1.2f\n', elapsed_time_cc)
    fprintf('Time taken for the reach set computation (lag-under): %1.2f\n', elapsed_time_lag)
end