# Evo_growth
Evolutionary Intertemporal Decision Rules in a Growth Model

Implemented in Julia 1.3.1 https://julialang.org/


To run the simulation / replicate the results.
1.	Set parameters in q_set_para_initial() in the file setup_functions.jl.
2.	Run the program  Run_learning.jl to observe the evolution of the the decsion rule and the associated savings rates / capital levels. The final set of descion rule parameters is saved for step #3.
3.	Run the program  Run_simulation.jl to simulate one generation with the parameters obtained previously.


Run_learning.jl
Runs the simulation to obtain the parameters for the intertemporal decision function.
Before running this program set the simulation parameters in the function q_set_para_initial() in the file setup_functions.jl.


Run_simulation.jl
Simulates one generation with the parameters obtained previously. Run after running run_learning.jl
