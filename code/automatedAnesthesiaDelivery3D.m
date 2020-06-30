%% Underapproximative verification of an automated anesthesia delivery system
% 
% Convex chance-constraint+open-loop-based underapproximation to construct the
% stochastic reach set for automated anesthesia delivery system at prob_thresh = 0.99

fprintf('\n\nautomatedAnesthesiaDelivery 3D\n');

%% Problem Formulation
% We first define a |LtiSystem| object corresponding to the discrete-time 
% approximation of the three-compartment pharmacokinetic system model.
%
% We bound the anesthesia the automation can deliver to $[0,7]$ mg/dL and
% account for patient model mismatch via an additive Gaussian noise.

% System matrices: State matrix and input matrix
% ----------------------------------------------
systemMatrix = [0.8192, 0.03412, 0.01265;
                0.01646, 0.9822, 0.0001;
                0.0009, 0.00002, 0.9989];
inputMatrix = [0.01883;
               0.0002;
               0.00001];
% Input bounds
% ------------
auto_input_max = 7;  

% Process disturbance with a specified mean and variance
% ------------------------------------------------------
dist_mean = 0;
dist_var = 5;
process_disturbance = RandomVector('Gaussian',dist_mean, dist_var);

% LtiSystem definition                                        
sys = LtiSystem('StateMatrix', systemMatrix, ...
                'InputMatrix', inputMatrix, ...
                'DisturbanceMatrix', inputMatrix, ...
                'InputSpace', Polyhedron('lb', 0, 'ub', auto_input_max), ...
                'Disturbance', process_disturbance);

%% Safety specifications
% We desire that the state remains inside a set $\mathcal{K}=\{x\in
% \mathbf{R}^3: 0\leq x_1 \leq 6, 0\leq x_2 \leq 10, 0\leq x_3 \leq 10 \}$.
time_horizon = 10;
safe_set = Polyhedron('lb',[1, 0, 0], 'ub', [6, 10, 10]);
safety_tube = Tube('viability',safe_set, time_horizon);

%% Computation of the underapproximation of the stochastic viability set
% We are interested in computing the stochastic viability set at
% probability 0.99.
%
% Safety probability threshold of interest
% ----------------------------------------
prob_thresh = 0.99;     % Stochastic reach-avoid 'level' of interest

% Definition of set of direction vectors
% --------------------------------------
% no_of_dir_vecs = 30;
% verbose_spread = 0;
% set_of_dir_vecs = spreadPointsOnUnitSphere(sys.state_dim, ...
%     no_of_dir_vecs, verbose_spread);
% For the report, we used
load('/data/set_of_dir_vecs_automated_anesthesia.mat', 'set_of_dir_vecs');

% Use SReachSet to compute the underapproximative set
% ---------------------------------------------------
% Use Ctrl + F1 to get the hints                                             
options = SReachSetOptions('term','chance-open', 'verbose', 0, ...
    'set_of_dir_vecs', set_of_dir_vecs, 'compute_style', 'cheby');
fprintf('Convex chance-constrained approach for alpha=%1.2f\n', prob_thresh);
timer_val = tic;
[underapprox_stoch_reach_polytope_cco, extra_info_cco] = SReachSet('term', ...
    'chance-open', sys, prob_thresh, safety_tube, options); 
elapsed_time_cco = toc(timer_val);

%% Plotting the stochastic viable set
figure(1);
clf;
hold on;
plot(safe_set, 'color', 'y','alpha',0.3);
plot(underapprox_stoch_reach_polytope_cco, 'color', 'm', 'alpha', 0.5);
leg=legend({'Safe set','Underapproximative polytope'});
set(leg,'Location','best');
xlabel('$x_1$','interpreter','latex')
ylabel('$x_2$','interpreter','latex')
zlabel('$x_3$','interpreter','latex')
box on;
axis tight;axis equal;
title('Underapprox. stochastic reach-avoid set (Anesthesia)');
saveas(gcf, '../results/automatedAnesthesia_StochasticViabilitySet.png');

% Display the results
% -------------------
fprintf('Time taken for the reach set computation: %1.2f\n', elapsed_time_cco);
ratio_volume = underapprox_stoch_reach_polytope_cco.volume/safe_set.volume;
fprintf('Ratio of volume (3D): %1.2f\n', ratio_volume)
max_reach_prob = extra_info_cco(1).xmax_reach_prob;
fprintf('Lower bound on the maximum reach probability: %1.2f\n', max_reach_prob)
save('../results/automatedAnesthesiaDelivery3D.mat');
