# ARCH2020: SReachTools code for ARCH-COMP20 Category Report: Stochastic Models

We provide SReachTools code base used for "ARCH 2020 Category Report: Stochastic
Models" repeatability evaluation. We tested SReachTools on three different
benchmarks --- automated anesthesia delivery system, building automation system,
and chain of integrators. 

The table used in ARCH-COMP 2020 report is given `results/table.csv`.

This codebase has been tested on the following platforms:

1. AWS server (http://mkhaled-aws.ddns.net/), and 
1. CodeOcean (https://doi.org/10.24433/CO.5339956.v1). 

We used GUROBI, a commercial solver, in the AWS server. These results were
utilized in creating the table for the report.

We used SeDuMi, a free solver that ships with CVX, in the CodeOcean capsule.
Note that SeDuMi could not reliably solve n in {40, 100} cases in the chain of
integrator. The CodeOcean capsule takes about 3 minutes to setup and complete
the computation without the time-consuming benchmarks (n={10, 20}), while it
takes 7 additional minutes to finish the last two cases.

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
- **(optional)** GUROBI (tested on version 9.0.2) http://www.gurobi.com

### How do I reproduce the results?

1. Setup the environment with above described dependencies installed
1. Clone this repository
1. Run the script `code/runall.m`.  

### Where are the results of the experiments?

The script `parseMatfilesResults.m` (run automatically by `runall.m`) extracts
relevant information for the matfiles produced during the experiments for the
table.

#### AWS server

- We store the table in `results/table.csv`.
- The results of the experiments are stored in the folder `results/`.

#### CodeOcean

- We store the table in `results/table.csv`.
- The results of the experiments are stored in the folder `results`.

## Contact

If you have any questions, please contact aby.vinod@gmail.com
