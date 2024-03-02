# written by Shane Parr <shane.parr@brown.edu>

module TaxiEnv

export TaxiState, Action, init_taxi_env, step!, reset, render

struct TaxiState
    taxi_row::Int
    taxi_col::Int
    passenger_loc::String
    passenger_status::Bool
    destination::String
    taxi_map::Array{String, 2}
end

Depots = Dict("r" => (1, 1), "g" => (5, 1), "b" => (5, 5), "y" => (1,5))
Depots_rev = Dict((1,1) => "r", (5,1) => "g", (5,5) => "b", (1,5) => "y")
@enum Action begin
    North = 1
    South
    East
    West
    Pickup
    Dropoff
end

function init_taxi_env()
    standard_map = [
        "r."  " ." "|." " ." "g.";
        " ."  " ." "|." " ." " .";
        " ."  " ." " ." " ." " .";
        " ."  "|." " ." "|." " .";
        "y."  "|." " ." "|." "b."
    ]
    start_state = TaxiState(2, 2, "r", false, "b", standard_map)
    return start_state
end

function step!(state::TaxiState, action::Action)
    row, col = state.taxi_row, state.taxi_col
    map = state.taxi_map
    reward = -1
    done = false
    new_row = row
    new_col = col
    new_status = state.passenger_status
    new_pass_loc = state.passenger_loc
    if action == North
        new_row, new_col = row - 1, col
    elseif action == South
        new_row, new_col = row + 1, col
    elseif action == East
        new_row, new_col = row, col + 1
    elseif action == West
        new_row, new_col = row, col - 1
    elseif action == Pickup
        if !state.passenger_status && Depots[state.passenger_loc] == (state.taxi_row, state.taxi_col)
            new_status = true #passenger is now in taxi
        else
            reward = -10 #failed to pick up passenger
        end
    elseif action == Dropoff
        if (state.taxi_row, state.taxi_col) in values(Depots) && state.passenger_status
            new_status = false
            new_pass_loc = Depots_rev[(state.taxi_row, state.taxi_col)]
            if new_pass_loc == state.destination
                reward = 20
                done = true
            end
        end
    end
    #check bounds and walls
    if  (new_row < 1 || 5 < new_row) ||
        (new_col < 1 || 5 < new_col) ||
        map[new_row, new_col] == "|." && action == East || 
        map[row, col] == "|." && action == West
        new_row, new_col = row, col
    end

    new_state = TaxiState(new_row, new_col, new_pass_loc, new_status, state.destination, state.taxi_map)

    return new_state, reward, done
end

function reset()
    return init_taxi_env()
end

function render(state::TaxiState)
    map = copy(state.taxi_map)  # make a copy so as not to modify the original map
    
    # Place the destination on the map
    dest_row, dest_col = Depots[state.destination]
    map[dest_row, dest_col] = "D."
    
    if state.passenger_status == false
        # place an empty taxi
        map[state.taxi_row, state.taxi_col] = replace(map[state.taxi_row, state.taxi_col], "." => "t")
        pass_row, pass_col = Depots[state.passenger_loc]
        # place a passenger on the map
        map[pass_row, pass_col] = replace(map[pass_row, pass_col], "." => "P")
   else
        # place a full taxi
        map[state.taxi_row, state.taxi_col] = replace(map[state.taxi_row, state.taxi_col], "." => "T")
   end
     
    
    # Print the map row by row
    for row in 1:size(map, 1)
        for col in 1:size(map, 2)
            print(map[row, col], " ")
        end
        println()  # Newline at the end of each row
    end
end

end # module TaxiEnv
