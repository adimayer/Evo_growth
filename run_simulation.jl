# simulate one generation for given set of parameters

ENV["GKS_ENCODING"] = "utf-8"
using LinearAlgebra, Statistics,  Distributions, Random,  Plots, JLD2
include("sim_functions.jl")
include("show_functions.jl")
include("setup_inital.jl")

#sim_set["shock_type"] = 1  # change to simulate actual shock different from shock used for expectations formation
include("setup_functions.jl")

# reset accouting -- account para not needed
account_econ, account_para = q_set_accounting(sim_set)
Random.seed!(sim_set["r_seed"])
gen_utility, state, account_econ = q_one_generation(state, s_para, econ_set, decide_set, sim_set, account_econ )

# show results
q_show_sim_rep(account_econ)
