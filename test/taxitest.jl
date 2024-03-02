# written by Shane Parr <shane.parr@brown.edu>

include("../env/TaxiEnv.jl")
using .TaxiEnv

init_state = TaxiEnv.init_taxi_env()

success_seq = 
Action[TaxiEnv.North, TaxiEnv.West, TaxiEnv.Pickup,
    TaxiEnv.South, TaxiEnv.South, TaxiEnv.East,
    TaxiEnv.East, TaxiEnv.East, TaxiEnv.East, 
    TaxiEnv.South, TaxiEnv.South, TaxiEnv.Dropoff]
failure_seq = 
Action[TaxiEnv.South, TaxiEnv.East, TaxiEnv.South,
    TaxiEnv.East, TaxiEnv.Pickup, TaxiEnv.Dropoff,
    TaxiEnv.West, TaxiEnv.West, TaxiEnv.North,
    TaxiEnv.North,TaxiEnv.North, TaxiEnv.North,
    TaxiEnv.West, TaxiEnv.Pickup, TaxiEnv.Dropoff,
    TaxiEnv.Pickup, TaxiEnv.South, TaxiEnv.Dropoff,
    TaxiEnv.South, TaxiEnv.South, TaxiEnv.South, 
    TaxiEnv.Dropoff, TaxiEnv.North, TaxiEnv.West]
render(init_state)
function run_sim(action_seq, state)
    new_state = state
    for idx in eachindex(action_seq)
        new_state, reward, done = TaxiEnv.step!(new_state, action_seq[idx])
        print(idx," ", reward," ", done)
        println()
        render(new_state)
    end
end

println("try successful sequence")

run_sim(success_seq, init_state)
println("try unsuccessful sequence")
init_state = TaxiEnv.reset()
render(init_state)
run_sim(failure_seq, init_state)
