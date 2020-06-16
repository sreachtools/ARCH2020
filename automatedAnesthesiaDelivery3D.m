%% Underapproximative verification of an automated anesthesia delivery system
% This example will demonstrate the use of |SReachTools| for controller
% synthesis and verification of a stochastic continuous-state discrete-time
% linear time-invariant (LTI) systems. This example script is part of the
% |SReachTools| toolbox, which is licensed under GPL v3 or (at your option) any
% later version. A copy of this license is given in
% <https://sreachtools.github.io/license/
% https://sreachtools.github.io/license/>.
% 
% In this example script, we discuss how to use |SReachSet| to synthesize
% open-loop controllers and verification for the problem of stochastic
% reachability of a target tube. Here, by verification, we wish to characterize
% a set of safe initial states with probabilistic safety above a threshold. We
% consider the verification of an automated anesthesia delivery model.
%
% Automated anesthesia delivery systems have the potential to significantly
% reduce medical operation costs by allowing a single human-anestheologist to
% monitor multiple operations and delegate the low-level regulation of the
% patient's sedation level to the automation. Naturally, this system is safety
% critical, and we wish to ascertain the set of initial states (patient sedation
% levels) from which the automated anesthesia delivery system can continue to
% maintain within pre-specified safe bounds. If the patient sedation levels go
% outside these bounds, the patient may suffer from serious health consequences.
% This problem has been characterized as a benchmark problem in Abate et. al,
% ARCH 2018 paper (<https://doi.org/10.29007/7ks7
% https://doi.org/10.29007/7ks7>). To obtain a LTI system description, we
% consider Problem 2.1.1 with no anestheologist-in-the-loop, but an additive
% Gaussian disturbance to model the human patients. This script improves upon
% the Figures 6 and 7 of Abate et. al, ARCH 2018 paper
% (<https://doi.org/10.29007/7ks7 https://doi.org/10.29007/7ks7>).
%
% All computations were performed using MATLAB on an Intel Xeon CPU with 3.7GHz
% clock rate and 16 GB RAM. 

% Prescript running: Initializing srtinit, if it already hasn't been initialized
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
% For using |SReachSet| with |chance-open| option, we need a set of direction 
% vectors and an affine hull (n-2 dimensional) intersecting the initial
% state. Since $x_3$ of the dynamics is slow, we fix it $x_3=5$ and analyze
% the rest of the system.

% Safety probability threshold of interest
% ----------------------------------------
prob_thresh = 0.99;     % Stochastic reach-avoid 'level' of interest
% Definition of set of direction vectors
% --------------------------------------
% no_of_dir_vecs = 30;
% verbose_spread = 0;
% set_of_dir_vecs = spreadPointsOnUnitSphere(sys.state_dim, ...
%     no_of_dir_vecs, verbose_spread
load('matfiles/set_of_dir_vecs_automated_anesthesia.mat', 'set_of_dir_vecs');
% Use SReachSet to compute the underapproximative set
% ---------------------------------------------------
% Use Ctrl + F1 to get the hints                                             
options = SReachSetOptions('term','chance-open', 'verbose', 0, ...
    'set_of_dir_vecs', set_of_dir_vecs, 'compute_style', 'cheby');
disp('>>> Chance-constraint-based underapproximation');
timer_val = tic;
[underapprox_stoch_viab_polytope, extra_info] = SReachSet('term', ...
    'chance-open', sys, prob_thresh, safety_tube, options); 
elapsed_time = toc(timer_val);

% %% Plotting the stochastic viable set
% figure(1);
% clf;
% hold on;
% plot(safe_set, 'color', 'y','alpha',0.3);
% plot(underapprox_stoch_viab_polytope, 'color', 'm', 'alpha', 0.5);
% leg=legend({'Safe set','Underapproximative polytope'});
% set(leg,'Location','bestoutside');
% xlabel('$x_1$','interpreter','latex')
% ylabel('$x_2$','interpreter','latex')
% box on;
% grid on;
% view([0,90]);
% title('Open-loop underapproximative stochastic viability set');
% % If code ocean, save the results
% % saveas(gcf, '../results/Anesthesia_StochasticViabilitySet.png');

% Display the results
% -------------------
fprintf('\n\nTime taken for the reach set computation: %1.2f\n', elapsed_time);
ratio_volume_3D = underapprox_stoch_viab_polytope.volume/safe_set.volume;
fprintf('Ratio of volume: %1.2f\n', ratio_volume_3D)
fprintf('Maximum probability point: %1.2f\n', extra_info(1).xmax_reach_prob)
save('matfiles/results/automatedAnesthesiaDelivery3D.mat');