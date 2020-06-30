# ARCH2020: SReachTools codebase

We provide SReachTools code base used for "ARCH 2020 Category Report: Stochastic
Models" repeatability evaluation. We tested SReachTools on three different
benchmarks --- automated anesthesia delivery system, building automation system,
and chain of integrators. 

We obtain the table reported in ARCH 2020 using the script
`code/parseMatfilesResults.m` (executed automatically by `runall.m`). We store
the table in `code/matfiles/results/table.csv` (locally) or in
`results/table.csv` (CodeOcean).

This codebase has been tested on CodeOcean (lINK TO BE ADDED) as well as AWS
server (http://mkhaled-aws.ddns.net/).  We used GUROBI, a commercial solver, in
producing the results for the report. However, for the CodeOcean capsule, we
used SeDuMi, a free solver that ships with CVX.  Note that SeDuMi could not
reliably solve n in {40, 100} cases in the chain of integrator. 

The CodeOcean capsule takes about 3 minutes to finish without the time-consuming
benchmarks (n={10, 20}), while it takes 7 additional minutes to finish the last
two cases..

### Few changes between the code used in AWS and CodeOcean

- We have commented parts of the code to omit testing the chain of integrators
  benchmark for dimension n in {10, 20, 40, 100} to save runtime. Please
  uncomment lines 58 to 81  in `runall.m` to evaluate these time-consuming cases
  as well.
- To reproduce the table from the report using GUROBI, do the following steps:
    1. Install GUROBI.
    1. Uncomment lines 4 to 9 in `presolve_setup`, and comment lines 13 to 14.

## Quick start

### Requirements

- SReachTools (tested on version 1.3.1) https://sreachtools.github.io/installation
    - MATLAB (tested on 2019a, 2020a)
        - MATLAB's Statistics and Machine Learning Toolbox
    - CVX (tested on version 2.2) http://cvxr.com/cvx/
    - MPT (tested on version 3.1) https://www.mpt3.org/
- **optional** GUROBI (tested on version 9.0.2) http://www.gurobi.com

### How do I reproduce the results?

1. Setup the environment with above described dependencies installed
1. Clone this repository, and run the
1. Run the script `code/runall.m`.  

### Where are the results of the experiments?

The results of the experiments in the folder `matfiles/results/`. The script
`parseMatfilesResults.m` (run automatically by `runall.m`) extracts the
information for the table from the matfiles.

## Contact

If you have any questions, please contact aby.vinod@gmail.com
