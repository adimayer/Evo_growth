# Evo_growth
Evolutionary Intertemporal Decision Rules in a Growth Model

To run the simulation / replicate the results.
1.	Set parameters in q_set_para_initial() in the file setup_functions.jl.
2.	Run the program  Run_learning.jl to obtain set of learned parmeters and resulting savings rates / capital levels
3.	Run_simulation.jl to simulate one generation with the parameters obtained previously.

Code is run in Julia Version 1.3.1 (2019-12-30), https://julialang.org/

Run_learning.jl
Runs the simulation to obtain the parameters for the intertemporal decision function.
Before running this program set the simulation parameters in the function q_set_para_initial() in the file setup_functions.jl.


Run_simulation.jl
Simulates one generation with the parameters obtained previously. Run after running run_learning.jl
