% n_intg = 2;
% cco_compute_style = 'max_safe_init';
prob_thresh = 0.8;
n_dir_vecs = 32;

fprintf('\n\nchainOfIntegrators %dD using %d vectors\n', n_intg, ...
    n_dir_vecs);
%% System definition
umax = 1;
dist_cov = 0.01;
sampling_time = 0.1;                           
sys = getChainOfIntegLtiSystem(n_intg, sampling_time, ...
    Polyhedron('lb',-umax,'ub',umax), ...
    RandomVector('Gaussian', zeros(n_intg,1), dist_cov * eye(n_intg)));

%% Setup the target tube
% safe set definition
xmax_safe = 10;
xmax_target = 8;
safe_set = Polyhedron('lb', -xmax_safe*ones(n_intg,1), 'ub', xmax_safe*ones(n_intg,1));
target_set = Polyhedron('lb', -xmax_target*ones(n_intg,1), 'ub', xmax_target*ones(n_intg,1));
% target tube definition
time_horizon = 5;
target_tube = Tube('reach-avoid', safe_set, target_set, time_horizon);

%% Computation of an underapproximative stochastic reach-avoid set
n_non_zeroed = 2;
x_fixed_init = zeros(n_intg - n_non_zeroed, 1);
set_of_direction_vectors_cco_2D = spreadPointsOnUnitSphere(2, n_dir_vecs, 0);
set_of_direction_vectors_cco = [set_of_direction_vectors_cco_2D;
                                zeros(n_intg - n_non_zeroed, n_dir_vecs)];
affine_hull_He = [zeros(n_intg - n_non_zeroed, n_non_zeroed), ...
                  eye(n_intg -n_non_zeroed), ...
                  x_fixed_init];
init_safe_set_affine_poly = Polyhedron('He', affine_hull_He);

fprintf('Chance constrained approach for alpha=%1.2f\n',prob_thresh);
timer_cco = tic;
cc_options = SReachSetOptions('term', 'chance-open', 'set_of_dir_vecs', ...
    set_of_direction_vectors_cco, 'init_safe_set_affine', ...
    init_safe_set_affine_poly, 'verbose', cco_verbose, ...
    'compute_style', cco_compute_style);
[underapproximate_stochastic_reach_avoid_polytope_cco, extra_info_cco] ...
    = SReachSet('term','chance-open', sys, prob_thresh, target_tube, ...
        cc_options);      
elapsed_time_cco = toc(timer_cco);

%% Disp results
fprintf('\n\nLower bound on reach-avoid probability (chance-open): %1.6f\n',...
    extra_info_cco(1).xmax_reach_prob)
fprintf('Time taken for the reach set computation (chance-open): %1.2f\n', ...
    elapsed_time_cco)
underapproximate_stochastic_reach_avoid_polytope_cco_2D = ...
    Polyhedron(underapproximate_stochastic_reach_avoid_polytope_cco.V(:, 1:2));
underapproximate_stochastic_reach_avoid_polytope_cco_2D.minVRep();
% safe_set_2D = Polyhedron(safe_set.V(:, 1:2));
% safe_set_2D.minVRep();
% safe_set_2D_volume = safe_set_2D.volume
safe_set_2D_volume = (xmax_safe * 2) ^2;
ratio_volume_2D = ...
    underapproximate_stochastic_reach_avoid_polytope_cco_2D.volume/...
        safe_set_2D_volume;
fprintf('Ratio of volume: %1.2f\n', ratio_volume_2D)
save(sprintf('matfiles/results/chainOfIntegrators%dD.mat', n_intg));
