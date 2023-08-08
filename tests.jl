include("dsl.jl")
include("utils.jl")
include("synthesizer.jl")

using Test

# Test 1: Simple Addition
dsl = create_example_dsl()
examples = [(Dict(:x => 1, :y => 2), 3), (Dict(:x => 3, :y => 4), 7), (Dict(:x => -1, :y => 1), 0)]
expected_output = Expr(:call, :add, :x, :y)
# output = search(dsl, examples, [:x, :y], 1)
output = search(dsl, examples, [["x"], ["y"]], 4)
@test output == expected_output

# Test 2: More Complex Expression
dsl = create_example_dsl()
examples = [(Dict(:x => 1, :y => 2, :z => 3), 7), (Dict(:x => 3, :y => 4, :z => 2), 11), (Dict(:x => -1, :y => 1, :z => 2), 1), (Dict(:x => 7, :y => 8, :z => 9), 79)]
expected_output = Expr(:call, :add, :x, Expr(:call, :multiply, :y, :z))
# output = search(dsl, examples, [:x, :y, :z], 2)
output = search(dsl, examples, [["x"], ["y"], ["z"]], 5)
@test output == expected_output
