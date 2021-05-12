# Evo_growth

Evolutionary Intertemporal Decision Rules in a Growth Model

Implemented in Julia 1.3.1 https://julialang.org/


To run the simulation / replicate the results.
1.  load all file into the project directory.
2.	Set parameters in q_set_para_initial() in the file setup_functions.jl.
3.	Run the program  Run_learning.jl to observe the evolution of the decision rule and the associated savings rates / capital levels. The final set of decision rule parameters is saved for step #4.
4.	Run the program  Run_simulation.jl to simulate one generation with the parameters obtained previously.



Files:

Run_learning.jl
Runs the simulation to obtain the parameters for the intertemporal decision function.
Before running this program set the simulation parameters in the function q_set_para_initial() in the file setup_functions.jl.


Run_simulation.jl
Simulates one generation with the parameters obtained previously. Run after running run_learning.jl


setup_functions.jl
Called while running the simulation
Defines the functions used within the simulation


setup_initial.jl
Contains the functions that specify simulation parameters and create initial values.


show_functions.jl
Containes the functions used to create the plots


sim_functions.jl
Contains functions used for the simulation.
Called while running the simulation.
