# define functions used
# give type , market_type, action_type, t_shock

println("market_type a ", sim_set["market_type"])
println("action_type a ", sim_set["action_type"])

if econ_set["prod_trans_type"] == 1
    q_draw_productivity_gen(productivity, product_trans, econ_set) = q_draw_productivity_norm(productivity, product_trans, econ_set)
else
    q_draw_productivity_gen(productivity, product_trans, econ_set) = q_draw_productivity_discrete(productivity, product_trans, econ_set)
end

# choose utility function
q_utility_gen(consume) = q_utility_log(consume)

if sim_set["type"] == 0
    if sim_set["action_type"] == 0  # simple number
        q_action_gen_one(input, para, scale, shock_p) = q_action_simple_one(input, para, scale, shock_p)
        n_decide_para = 1
    end
    if sim_set["action_type"] == 1 # linear
        q_action_gen_one(input, para, scale, shock_p) = q_action_lin_one_three(input, para, scale, shock_p)
        n_decide_para = 3
        println("n_decide_para ", n_decide_para)
    end
    if sim_set["action_type"] == 2 # polynomial inputs
        q_action_gen_one(input, para, scale, shock_p) = q_action_po_one_six(input, para, scale, shock_p)
        n_decide_para = 6
        println("n_decide_para ", n_decide_para)
    end
    if sim_set["action_type"] == 3 # neural net inputs
        q_action_gen_one(input, para, scale, shock_p) = q_action_nn_one_six(input, para, scale, shock_p)
        n_decide_para = 6
        println("n_decide_para ", n_decide_para)
    end
    if sim_set["action_type"] == 4  # linear shock dummy only
        q_action_gen_one(input, para, scale, shock_p) = q_action_lin_one_four(input, para, scale, shock_p)
        n_decide_para = 4
        println("n_decide_para ", n_decide_para)
    end
    if sim_set["action_type"] == 5 # linear inputs plus shock dummy
        q_action_gen_one(input, para, scale, shock_p) = q_action_lin_one_six(input, para, scale, shock_p)
        n_decide_para = 6
        println("n_decide_para ", n_decide_para)
    end
    if sim_set["action_type"] == 6  # poly inputs linear shock dummy
        q_action_gen_one(input, para, scale, shock_p) = q_action_po_one_nine(input, para, scale, shock_p)
        n_decide_para = 9
        println("n_decide_para ", n_decide_para)
    end

    # market type does not matter for rep agent model
    q_market_gen(supply, demand, post_price, price_para) = q_market_clear(supply, demand, post_price, price_para)
    price_para = [0, 0, 0]  # does not matter for rep agent model
    
    q_gen_period(state, s_para, econ_set, decide_set, account_a, shock_p) = q_rep_period(state, s_para, econ_set, decide_set, account_a, shock_p)
end

#
