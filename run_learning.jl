#  main learn parameters
#  runs simulation to learn parameters and equilibrium levels of capital

ENV["GKS_ENCODING"] = "utf-8"

# Julia libraries used
using LinearAlgebra, Statistics,  Distributions, Random,  Plots, JLD2
# project functions used
include("setup_inital.jl")
include("sim_functions.jl")
include("show_functions.jl")


println()
println()
println("********** Setup and Initial Values *************************")
Random.seed!(123)  # set random seed to

# define parameters for simulation --- change parameters in that function (file setup_functions.jl)
sim_set, decide_set, econ_set = q_set_para_initial()

# defines functions used in simulation -- e.g. production function, functional form of decsion rule, ...
include("setup_functions.jl")
econ_set["price_para"] = price_para    # adjust price para to fit market type

# set up accounting arrays that keeps track of variables over time
account_econ, account_para = q_set_accounting(sim_set)

# create initial values -- state of the world and parameters for decsions function
initial_set = q_set_initial_values(sim_set["type"], sim_set["n_agents"])
state = initial_set["state"]
s_para = initial_set["decide_para"]

println("   Setup complete  " )

println()
println()
println("********** Run Learn_shock simulation *************************")

# simulated the economy for specified number of gnerations
account_econ, account_para, s_para, state = q_one_run(state, s_para, econ_set, decide_set, sim_set, account_econ, account_para)

println(" run learn shock complete ")


# show results
q_show_results(state, s_para, econ_set, decide_set, sim_set, account_econ, account_para)
