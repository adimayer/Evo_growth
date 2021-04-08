# functions used in Simulation
# 1) functions that cycle through one period, one generation, several generations
# 2) functions events in each period, production, utility ...
# 3) functions for genetic algorithm
# 4) functions describing decsion rule
# 5) support functions


# functions that cycle through actions ##########################################
# one period, one generation, several gnerations

function q_rep_period(state, s_para, econ_set, decide_set, account_a, shock_p)
    # one period for representative agent
    # draw productivity, produce, savings decstion, determine new capital & utility
    # unpack variables
    mean_output = account_a[1]
    mean_consume = account_a[2]
    mean_capital = account_a[3]
    mean_s_rate = account_a[4]

    capital = state[1]
    productivity = state[2]
    n = length(capital)

    alpha = econ_set["alpha"]
    delta = econ_set["delta"]
    prod_level = econ_set["prod_level"]
    product_trans_p = econ_set["productivity_transition"]
    scale = decide_set["scale"]
    t_shock = shock_p[1]
    # draw productivity
    productivity = q_draw_productivity_gen(productivity, product_trans_p, econ_set)
    # produce
    output = prod_level * q_output_cobb(capital, productivity, alpha)
    # determine savings --
    input = hcat(capital, productivity)
    s_rate = q_action_gen_one(input, s_para, scale, shock_p)
    # consumption, utility,
    consume = output .* (ones(n) - s_rate)
    utility = q_utility_gen(consume)
    # new capital
    capital = capital * delta
    capital = capital + output .* s_rate
    # accounting
    append!(mean_output ,mean(output))
    append!(mean_consume, mean(consume))
    append!(mean_capital, mean(capital))
    append!(mean_s_rate, mean(s_rate))
    account_a = [mean_output, mean_consume, mean_capital, mean_s_rate]

    state = [capital, productivity]

    return state, utility, account_a
end

function q_one_generation(state, s_para, econ_set, decide_set, sim_set, account_econ)
    n, m = size(s_para)
    periods = sim_set["periods"]
    shock_duration = sim_set["shock_duration"]
    beta = econ_set["beta"]
    gen_utility = zeros(n)
    for i in 1:periods
        econ_set = q_shock(econ_set, sim_set, i)
        shock_p = [sim_set["t_shock"] sim_set["shock_duration"] i sim_set["periods"]]
        state,  utility, account_a = q_gen_period(state, s_para, econ_set, decide_set, account_econ, shock_p)
        gen_utility = gen_utility * (1/beta) +  utility
    end
    return gen_utility, state, account_econ
end

function q_one_run(state, s_para, econ_set, decide_set, sim_set, account_econ, account_para)
    generations = sim_set["generations"]
    type = sim_set["type"]
    println("type " , type)
    p_mutate = decide_set["mutation_prob"]

    for d in 1:generations
        println("Generation: ", d)
        if econ_set["reset_capital"] == 1    # reset capital to zero
            state[1] = state[1] ./state[1] * mean(state[1])
            if type == 2
                state[2] = state[2] ./state[2] * 10
            end
            if type == 1
                #state[3] = state[3] ./state[3] * mean(state[3])
                state[3] = state[3] ./state[3] * 10
                state[4] = state[4] ./state[4] * mean(state[4])
            end
        end
        gen_utility, state, account_econ = q_one_generation(state, s_para, econ_set, decide_set, sim_set, account_econ)
        s_para = q_learn(gen_utility, s_para, p_mutate)
        account_para=vcat(account_para,mean(s_para,dims=1))
    end

    return account_econ, account_para, s_para, state
end


#
function q_shock(econ_set, sim_set, period)
    #shock_type : 0 no shock ; 1 postitive productivity, 2 negative productivity, 3 positive cash
    shock_type = sim_set["shock_type"]

    if shock_type == 1
        # positive productivity
        if period == sim_set["t_shock"]
            econ_set["prod_level"] = econ_set["prod_level"] * 2
        elseif  period == sim_set["t_shock"] + sim_set["shock_duration"]
            econ_set["prod_level"] = econ_set["prod_level"] * .5
        end
    elseif shock_type == 2
            # negative productivity
            if period == sim_set["t_shock"]
                econ_set["prod_level"] = econ_set["prod_level"] * .5
            elseif  period == sim_set["t_shock"] + sim_set["shock_duration"]
                econ_set["prod_level"] = econ_set["prod_level"] * 2
            end
    elseif shock_type == 3
        # negative productivity
        if period == sim_set["t_shock"]
            econ_set["print_money"] = 2
        elseif  period == sim_set["t_shock"] + sim_set["shock_duration"]
            econ_set["print_money"] = 0
        end
    end
    return econ_set
end

function q_draw_productivity_norm(productivity, product_trans, econ_set)
    # give current productivity, transition paramaters [roh - sigma], type
    # return new productivity
    # roh -- gives persistence -- sigma variance of draw from normal distribution
    # lower bound zero -- for large variance skewed distribution
    raw_productivity = productivity ./ econ_set["prod_level"]
    n = length(raw_productivity)
    nnn = Normal(0, product_trans[2])
    qq = product_trans[1] * log.(raw_productivity) + rand(nnn,n)
    productivity = exp.(qq) * econ_set["prod_level"]
    return productivity
end

function q_output_cobb(capital, productivity, alpha)
    # cobb douglas productivity
    # give A (productivity), capital and alpha
    # set alpha = 0 to get: output = productivity
    if minimum(capital) < 0
        (temp_a, temp_b) = findmin(capital)
        println("value ", temp_a)
        println("position ", temp_b)
    end
    output = productivity .* capital .^alpha
    return output
end

function q_utility_log(consume)
    # give consumption return utility
    n = length(consume)
    utility = log.(consume + ones(n)*.0001)
    return utility
end


# evolutionary algorithm  ###########################################################################
# update parameters

function q_learn(utility, param, p_mutate)
    # give utility and parameters for each agent
    # return new list of parameters
    # p_mutate probablity that each gen of offspring will mutate
    utility = utility * (-1)   # maximize
    # creat matrix that can be sorted
    n , n_param  = size(param)
    id = [1:n;]
    A= [id utility param]
    A = A[sortperm(A[:, 2]), :]   # sort

    # select and breed
    n_breed = Int(floor(n/2))           # share of agents who get to breed
    breeders = A[1:n_breed,3:end]     # pick best performing agents
    bmix = breeders[shuffle(1:end),:]  # shuffle them
    lottery = rand(0:1,n_breed,n_param) # 0 or 1 random for number breeders x parameters
    replace = breeders .* lottery + bmix .* (ones(n_breed,n_param)-lottery) # newly created genes  combine genes of breeders

    # mutation -- mutate some of the new genes
    d = Binomial(1, p_mutate)
    mutate = rand(d,n_breed,n_param)
    mutation = q_draw_para(n_breed, n_param)  # draw new parameters  -- use for mutations
    replace = replace .* (ones(n_breed,n_param)-mutate)  + mutation .* mutate

    # replace
    A[end-n_breed+1:end,3:end] = replace
    A = A[sortperm(A[:, 1]), :]
    new_para = A[:,3:end]
    return new_para
end

function q_draw_para(n, n_para)
    # random draw parameters -- for n agents -- n_para each
    draws = rand(n, n_para)   # uniform distribution
    #draws = rand(n,n_param) .* rand(n,n_param) # skewed towards zero
    draws = round.(draws, digits = 2)
    return draws
end


# functions for that decribe the decsion rule  #########################

function q_action_simple_one(input, para, scale, shock_p)  # simple number
    # returns one parameter between 0 and 1
    # igonores inputs

    n, m = size(input)
    ss = scale * (2 * para[:,1] - ones(n))
    sss = broadcast(sigmoid,ss) *.99
    return sss
end

function q_action_lin_one_three(input, para, scale, shock_p)  # linear inputs
    # give: two inputs capital (cash) and productivity, 3 parameters
    # return rate savings s_rate
    # sigmoid to ensure between 0 and 1
    # scale  within sigmoid
    # parameters are between zero and one => therefore mitiply by 2 and minus one to get -1 to + 1
    capital = input[:,1]
    productivity = input[:,2]
    n = length(capital)
    temp_x = scale * ((2 * para[:,1] - ones(n)) + (capital .* (2 * para[:,2] - ones(n))) + (productivity .* (2 * para[:,3] - ones(n))))
    s_rate = broadcast(sigmoid,temp_x) *.99
    return s_rate
end

function q_action_po_one_six(input, para, scale, shock_p)   # polynolial inputs
    # give: capital (cash) and productivity, 6 parameters
    # return savings rate
    # polynomial
    # scale coefficients
    # eventually write in matrix notation and generalize
    capital = input[:,1]  # or cash for simple CIA
    productivity = input[:,2]
    n = length(capital)
    temp_a = (2 * para[:,1] - ones(n)) + (capital .* (2 * para[:,2] - ones(n))) + (productivity .* (2 * para[:,3] - ones(n)))
    temp_b = capital .^2 .* (2 * para[:,4] - ones(n)) + productivity .^2 .* (2 * para[:,5] - ones(n))
    temp_c = capital .*productivity .* (2 * para[:,6] - ones(n))
    temp_t = scale * (temp_a + temp_b + temp_c)
    s_rate = broadcast(sigmoid,temp_t) *.99
    return s_rate
end

function q_action_nn_one_six(input, para, scale, shock_p)  # neural net inputs
    # give: capital (cash) and productivity, 6 parameters
    # return savings rate
    # neural network
    # calls q_nnet_two
    # scales coefficients first

    capital = input[:,1]  # or cash in case of simple CIA\
    productivity = input[:,2]
    n_agents = length(capital)
    para_u = scale * (2 * para - ones(n_agents,6))  # transform para from (0;1) to (-scale; + scale)
    FL = zeros(n_agents,2,2)
    FL[:,1,:] = para_u[:,1:2]
    FL[:,2,:] = para_u[:,3:4]
    SL = zeros(n_agents,2,1)
    SL[:,:,1] = para_u[:,5:6]
    input = hcat(capital, productivity)

    qqq = q_nnet_two(input, FL, SL ) *.99
    return qqq
end

# with shocks

function q_action_lin_one_four(input, para, scale, shock_p)    # linear shock dummy only
    # ignores inputs -- considers shock only
    # returns one number between zero and one
    n = length(input[:,1])
    d_shock_a, d_shock_b, d_shock_c = q_shock_dummy(shock_p)
    temp_x = scale * ((2 * para[:,1] - ones(n))
     + (d_shock_a .* (2 * para[:,2] - ones(n)))   + (d_shock_b .* (2 * para[:,3] - ones(n)))  + (d_shock_c .* (2 * para[:,4] - ones(n))) )
    s_rate = broadcast(sigmoid,temp_x) *.99
    return s_rate
end

function q_action_lin_one_six(input, para, scale, shock_p)  # linear inputs plus shock dummy
    # linear inputs and shock dummies
    capital = input[:,1]  # or cash in case of simple CIA\
    productivity = input[:,2]
    d_shock_a, d_shock_b, d_shock_c = q_shock_dummy(shock_p)
    n = length(capital)
    temp_x = scale * ((2 * para[:,1] - ones(n)) + (capital .* (2 * para[:,2] - ones(n))) + (productivity .* (2 * para[:,3] - ones(n)))
     + (d_shock_a .* (2 * para[:,4] - ones(n)))   + (d_shock_b .* (2 * para[:,5] - ones(n)))  + (d_shock_c .* (2 * para[:,6] - ones(n))) )
    s_rate = broadcast(sigmoid,temp_x) *.99
    return s_rate
end

function q_action_po_one_nine(input, para, scale, shock_p)  # poly inputs linear shock dummy
    # polynomial on inputs & linear shock
    # give: capital (cash) and productivity and shock dummies
    # 6 parameters
    # return savings rate
    # polynomial
    # scale coefficients
    # eventually write in matrix notation and generalize
    capital = input[:,1]  # or cash for simple CIA
    productivity = input[:,2]
    n = length(capital)
    d_shock_a, d_shock_b, d_shock_c = q_shock_dummy(shock_p)
    temp_a = (2 * para[:,1] - ones(n)) + (capital .* (2 * para[:,2] - ones(n))) + (productivity .* (2 * para[:,3] - ones(n)))
    temp_b = capital .^2 .* (2 * para[:,4] - ones(n)) + productivity .^2 .* (2 * para[:,5] - ones(n))
    temp_c = capital .*productivity .* (2 * para[:,6] - ones(n))
    temp_d = scale * ((d_shock_a .* (2 * para[:,7] - ones(n)))   + (d_shock_b .* (2 * para[:,8] - ones(n)))  + (d_shock_c .* (2 * para[:,9] - ones(n))) )
    temp_t = scale * (temp_a + temp_b + temp_c)
    s_rate = broadcast(sigmoid,temp_t) *.99
    return s_rate
end

# support functions ##################################################

sigmoid(z::Real) = one(z) / (one(z) + exp(-z))

function q_nnet_two(input, f_FL, f_SL )
    # two layer neural network
    # give input and coefficients for first and second layer
    # coefficient values from -10 to +10
    # return output

    n , i_s = size(input)
    n , h_l, o_l = size(f_SL)
    output = rand(n, o_l)
    for i in 1:n
        HL = input[i,:]' * f_FL[i,:,:]
        #HL = broadcast(sigmoid,HL)
        output[i,:] = HL * f_SL[i,:,:]
    end
    output = broadcast(sigmoid,output)
    return output
end

function q_shock_dummy(shock_p)
    #shock_p = [time of_shock, shock_duration, current period, total_periods]
    d_shock_a = (shock_p[3] >= (shock_p[1])) && (shock_p[3] < (shock_p[1] + shock_p[2])) + 0.0
    d_shock_b = (shock_p[3] < (shock_p[1])) && (shock_p[3] >= (shock_p[1] - 2)) + 0.0
    d_shock_c = (shock_p[3] >= (shock_p[1] + shock_p[2])) && (shock_p[3] < (shock_p[1] + shock_p[2]) + 2) + 0.0
    return d_shock_a, d_shock_b, d_shock_c
end
