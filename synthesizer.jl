using Printf
using Base.Iterators: product



function generate_candidates(dsl::DSL, arguments::Array{Symbol, 1}, max_depth::Int)
    # Create an array of sets for each depth level
    # Vector{Any}[] instead of []
    depth_exprs = [[] for _ in 0:max_depth]

    # Initialize depth 0 set with arguments and 0-arity primitives
    depth_exprs[1] = [arg for arg in arguments]
    for primitive in dsl.primitives
        if primitive.arity == 0
            push!(depth_exprs[1], Expr(:call, Symbol(primitive.name)))
        end
    end

    # Build expressions from depth 1 to max_depth
    for d in 1:max_depth
        for primitive in dsl.primitives 
            if primitive.arity >= 1
                n = primitive.arity
                possibilities = vcat([depth_exprs[i] for i in 1:d]...)
                arg_combinations = product(fill(possibilities, n)...)
                for arg_combination in arg_combinations
                    # create an expression
                    new_expr = Expr(:call, Symbol(primitive.name), arg_combination...)
                    # push the new expression and its corresponding depth to the queue
                    push!(depth_exprs[d+1], new_expr)
                end
            end
        end
        @debug depth_exprs[d]
    end
    # Return the union of all depth 0 to depth max_depth expressions
    return vcat(depth_exprs...)
end


function evaluate_candidates(candidates, examples)
    scores = Dict()
    for candidate in candidates
        scores[candidate] = 0
        for example in examples
            inputs, output = example
            if evaluate(candidate, inputs) == output
                scores[candidate] += 1
            end
        end
    end
    return scores
end

function search(dsl::DSL, examples, arguments::Array{Symbol, 1}, max_depth::Int)
    candidates = generate_candidates(dsl, arguments, max_depth)
    print(candidates)
    scores = evaluate_candidates(candidates, examples)
    best_candidate = argmax(scores)
    return best_candidate
end
