for meta in [false, true]
    for cfg in [false, true]
        config = Dict(
            "meta" => meta,
            "cfg" => cfg,
        )

        # Test 1: Simple Addition
        dsl = create_example_dsl()
        examples = [(Dict(:x => 1, :y => 2), 3), (Dict(:x => 3, :y => 4), 7), (Dict(:x => -1, :y => 1), 0)]
        expected_output = Expr(:call, :add, :x, :y)
        if cfg
            max_depth = 4
        else
            max_depth = 1
        end
        output = search(config, dsl, examples, ["x", "y"], max_depth)
        @test output == expected_output

        # Test 2: More Complex Expression
        dsl = create_example_dsl()
        examples = [(Dict(:x => 1, :y => 2, :z => 3), 7), (Dict(:x => 3, :y => 4, :z => 2), 11), (Dict(:x => -1, :y => 1, :z => 2), 1), (Dict(:x => 7, :y => 8, :z => 9), 79)]
        expected_output = Expr(:call, :add, :x, Expr(:call, :multiply, :y, :z))
        if cfg
            max_depth = 5
        else
            max_depth = 2
        end
        output = search(config, dsl, examples, ["x", "y", "z"], max_depth)
        @test output == expected_output
    end
end