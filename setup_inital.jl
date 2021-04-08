# functions to set parameters and to creat inital values


function q_set_para_initial()
    # set parameters

    # model type and shock
    type = 0 # 0 - rep agent ;; do not change
    action_type = 5 # type of action function - 0 constant /  1 linear / 2 polynomial.... see setup_functions.jl
    market_type = 0 # not relevant for representative agent model
    shock_type = 2 # 0 nothing , 1 postitive productivity, 2 negative productivity
    t_shock = 20 #0 default; otherwise period at which shock happens -- if bigger than periods nothing happens -- set shock duration below
    shock_duration = 5  # 1 to something , number of periods shock is lasting -- do not set to zero
    r_seed = 123

    # simulation parameters
    n_agents = 5000  # number of agents -- default 5000
    periods = 50  # number of periods in each generation --- default 50 for shock, 200 without shock
    generations = 100 # number of gnerations default 1000
    reset_capital = 1   # if =1 capital reset for each new generation to populations average
    sim_set = Dict("n_agents" => n_agents, "periods" => periods, "generations" => generations, "r_seed" => r_seed,
    "type"=> type, "action_type" => action_type, "market_type" => market_type , "t_shock" => t_shock, "shock_duration" => shock_duration, "shock_type" => shock_type )

    # choice and learning parameters
    scale = 10   # inside decsion function - maps (0;1) parameters to (-scale;+scale) used inside sigmoid function, default 10
    mutation_prob = .01  # probablity that new learning parmeter is mutated, default .01
    decide_set = Dict("scale" => scale, "mutation_prob" => mutation_prob )

    # economy parameters
    prod_level = 1   # productivity level, default 1
    prod_trans_type = 1 # type of productivity shock: 0 discrete ; 1 normal  -- for standard growth model: 1
    product_trans_p = [.9, 0.1]  # low to high, high to high --- or for transition type 1  roh and sigma --  roh persitence -- sigma variance of new draw, default .9 and .1
    alpha = .25  # parameter for for production function
    beta = 1   # discount rate utility
    delta = 0.5      # depreciation capital  0 full depreciation 1 nothing depreciates
    price_para = [0, .1, 0.1]  # not relevant for representative agent model
    print  = 0 # not relevant for representative agent model
    econ_set = Dict("prod_level"=> prod_level, "prod_trans_type"=> prod_trans_type, "productivity_transition"=> product_trans_p, "alpha" => alpha, "beta" => beta, "delta" => delta, "reset_capital" => reset_capital, "price_para" => price_para, "print_money" => print )

    return sim_set, decide_set, econ_set
end

function q_set_accounting(sim_set)
    # set up array to keep track of simulation results
    type = sim_set["type"]
    action_type = sim_set["type"]
    market_type =sim_set["type"]
    # accounting
    # economy features recordecd every period
    # output, capital, consumption, save_rate
    mean_output = zeros(0)
    mean_consume = zeros(0)
    mean_capital = zeros(0)
    mean_s_goods = zeros(0)
    mean_s_cash = zeros(0)
    mean_price = zeros(0)
    mean_cash = zeros(0)

    account_econ = [mean_output, mean_consume, mean_capital, mean_s_goods, mean_s_cash, mean_price, mean_cash]

    # parameters for decsions recorded every generation
    account_para = zeros(0,n_decide_para)

    return account_econ, account_para
end

function q_set_initial_values(type, n_agents)
    # set initial values
    productivity = ones(n_agents)
    capital = ones(n_agents)
    cash = ones(n_agents) * 20
    price = ones(n_agents)
    s_cash = ones(n_agents) * .5   # save rate cash
    s_goods = ones(n_agents) * .5
    if type == 1
        state = [capital, productivity, cash, price, s_cash, s_goods]
    elseif type == 2
        state = [productivity, cash, price, s_cash]
    else
        state = [capital, productivity]
    end
    decide_para = q_draw_para(n_agents, n_decide_para)
    initial_set = Dict( "state" => state, "decide_para" => decide_para)
return initial_set
end
