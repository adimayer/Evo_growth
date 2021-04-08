# function that display the results

function q_show_rep_a(account_a, account_b)
    gens, n_para = size(account_b)
    mean_output = account_a[1]
    mean_consume = account_a[2]
    mean_capital = account_a[3]
    mean_s_rate = account_a[4]

    println("mean_output: ", mean_output[end])
    println("mean_consume: ", mean_consume[end])
    println("mean_capital: ", mean_capital[end])
    println("mean_s_rate: ", mean_s_rate[end])

    periods = length(mean_output)
    rr = floor(periods / gens)

    waste_b = 1
    waste_a =Int((waste_b-1) * rr + 1)

    p1 = plot(waste_a:periods, [mean_output[waste_a:end] mean_consume[waste_a:end]], title ="output & consumption",  label ="")
    p2 = plot(waste_a:periods, mean_capital[waste_a:end], title ="capital", label ="")
    p3 = plot(waste_a:periods, mean_s_rate[waste_a:end], title ="savings rate", label ="")
    if n_para == 1
        p4 = plot(waste_b:gens, account_b[:,1][waste_b:end] , title ="Para a", label ="")
        plot(p3, p2, p1, p4, layout=(2,2))
    elseif n_para == 3
        p4 = plot(waste_b:gens, [account_b[:,1][waste_b:end] account_b[:,2][waste_b:end] account_b[:,3][waste_b:end]], title ="Para a,b", label ="")
        plot(p3, p2, p1, p4, layout=(2,2))
    elseif n_para == 4
        p4 = plot(waste_b:gens, [account_b[:,1][waste_b:end] account_b[:,2][waste_b:end] account_b[:,3][waste_b:end] account_b[:,4][waste_b:end]], title ="Para a,b", label ="")
        plot(p3, p2, p1, p4, layout=(2,2))
    else
        p4 = plot(waste_b:gens, [account_b[:,1][waste_b:end] account_b[:,2][waste_b:end]] , title ="Para a,b", label ="")
        p5 = plot(waste_b:gens, [account_b[:,3][waste_b:end] account_b[:,4][waste_b:end]] , title ="Para c,d", label ="")
        p6 = plot(waste_b:gens, [account_b[:,5][waste_b:end] account_b[:,6][waste_b:end]],  title ="Para e,f", label ="")
        plot(p3, p2, p1, p4, p5, p6, layout=(3,2))
    end
end

function q_show_sim_rep(account_a)
    mean_output = account_a[1]
    mean_consume = account_a[2]
    mean_capital = account_a[3]
    mean_s_rate = account_a[4]
    periods = length(mean_output)

    println("mean_output: ", mean_output[end])
    println("mean_consume: ", mean_consume[end])
    println("mean_capital: ", mean_capital[end])
    println("mean_s_rate: ", mean_s_rate[end])


    yMin_s = minimum(mean_s_rate) * .9
    yMax_s = maximum(mean_s_rate) * 1.1

    yMin_c = minimum(mean_capital) * .9
    yMax_c = maximum(mean_capital) * 1.1

    waste_a = 1
    p1 = plot(waste_a:periods, [mean_output[waste_a:end] mean_consume[waste_a:end]], title ="Output & Consumption",  label ="")
    p2 = plot(waste_a:periods, mean_capital[waste_a:end], title ="Capital", ylim=(yMin_c, yMax_c), label ="")
    p3 = plot(waste_a:periods, mean_s_rate[waste_a:end], title ="Savings Rate", ylim=(yMin_s, yMax_s), label ="")
    plot(p1, p2, p3,  layout=(3,1))
end

function q_show_eval_r_plot(e_para, decide_set)
    scale =  decide_set["scale"]

    x=range(0,stop=1,length=100)
    y=range(0,stop=1,length=100)

    println()
    function q_eval_a(capital,productivity)
        shock_p = [sim_set["t_shock"] sim_set["shock_duration"] 1 sim_set["periods"]]
        input = hcat(capital, productivity)
        ss = q_action_gen_one(input, e_para, scale, shock_p)
        return ss[1]
    end

    function q_e_display()
        a_f_eva = zeros(3,3)
        e_input = ones(1,2)
        for e_cap in 1:3
            e_input[1] = e_cap
            for e_prod in 1:3
                e_input[2] = e_prod
                shock_p = [sim_set["t_shock"] sim_set["shock_duration"] 1 sim_set["periods"]]
                dd = q_action_gen_one(e_input, e_para, scale, shock_p)
                a_f_eva[e_cap,e_prod]= dd[1]
            end
        end
    end

    q_e_display()
    display(plot(x,y,q_eval_a,st=:surface,camera=(-10,30)))
    return
end


function q_show_eval_rep(para, state, sim_set, decide_set)

    println()
    println("capital min mean max ", minimum(state[1]), "  ", mean(state[1]),"  ", maximum(state[1]), " std ", std(state[1]) )
    println("productivity min mean max ", minimum(state[2]), "  ", mean(state[2]),"  ", maximum(state[2]), " std ", std(state[2]) )
    println()
    println("para : ", para)
    shock_p = [sim_set["t_shock"] sim_set["shock_duration"] 1 sim_set["periods"]]
    ca = maximum( [mean(state[1]) - std(state[1]), 0.0])
    cs = std(state[1])
    pa = maximum( [mean(state[2]) - std(state[2]), 0.0])
    ps = std(state[2])
    dd= zeros(3,3)
    for i in 1:3
        for j in 1:3
            e_inputs = [(ca + (i-1)*cs) (pa + (j-1)*ps) ]
            qd = q_action_gen_one(e_inputs, para, decide_set["scale"], shock_p)
            dd[i,j] = qd[1]
        end
    end
    println("row: capital, col:productivity")
    show(stdout, "text/plain", dd)
    println()
end

function q_show_results(state, s_para, econ_set, decide_set, sim_set, account_econ, account_para)
    type =  sim_set["type"]
    action_type =  sim_set["action_type"]
    market_type =  sim_set["market_type"]
    shock_type =  sim_set["shock_type"]
    shock_duration =  sim_set["shock_duration"]
    scale =  decide_set["scale"]
    println()
    println("Simulation Complete")
    println("Type: ", type)
    println("Decsion_function_Type: ", action_type )
    println("sim_set: ", sim_set)
    println("decide_set: ", decide_set)
    println("econ_set: ", econ_set)

    # visualize decsion function
    e_para = account_para[end:end,:]  # last mean parameters
    println("Representative Agent")
    println("e_para ", e_para)
    println("show a")
    oo = q_show_eval_rep(e_para, state, sim_set, decide_set)
    q_show_eval_r_plot(e_para, decide_set)
    q_show_rep_a(account_econ, account_para)
end
