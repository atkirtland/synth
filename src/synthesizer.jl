using Printf
using Base.Iterators: product

include("utils.jl")


function synthesize(dsl::DSL, inputs, outputs)
    # plist = dsl.grammar["CONST"]
    plist = Set{Union{Expr,Symbol}}([Symbol(var[1]) for var in dsl.grammar["CONST"]])
    while (true)
        @debug println(plist)
        plist = grow(dsl, plist)
        @debug println("bar", plist)
        plist = elimEquivalents(dsl, plist, inputs)
        for p in plist
            if isCorrect(dsl, p, inputs, outputs)
                return p
            end
        end
    end
end

function grow(dsl::DSL, plist::Set{Union{Expr,Symbol}})
    # new_plist = dsl.grammar["CONST"]
    new_plist = Set{Union{Expr,Symbol}}([Symbol(var[1]) for var in dsl.grammar["CONST"]])
    for option in dsl.grammar["EXPR"]
        if option[1] == "CONST"
            continue
        end
        for p1 in plist
            for p2 in plist
                push!(new_plist, Expr(:call, Symbol(option[1]), p1, p2))
            end
        end
    end
    return new_plist
end

function elimEquivalents(dsl::DSL, plist::Set{Union{Expr,Symbol}}, inputs)
    outputSet = Set([])
    programSet = Set{Union{Expr,Symbol}}([])
    for p in plist
        outputs = (evaluate(p, dsl, input) for input in inputs)
        if outputs in outputSet
            continue
        end
        push!(outputSet, outputs)
        push!(programSet, p)
    end
    return programSet
end

function isCorrect(dsl::DSL, p, inputs, outputs)
    for (input, output) in zip(inputs, outputs)
        if evaluate(p, dsl, input) != output
            return false
        end
    end
    return true
end


function search(
    config::Dict{String},
    dsl::DSL, 
    examples, 
    arguments::Vector{String}, 
    max_depth::Int
    )

    if config["cfg"] && !config["meta"]
        dsl.grammar["CONST"] = [[k] for k in arguments]
        inputs, outputs = collect(zip(examples...))
        synthesize(dsl, inputs, outputs)
    end
end

## pre-OE

function generate_candidates_from_cfg(grammar, symbol, max_depth)
    if max_depth == 0 || !haskey(grammar, symbol)
        return symbol in keys(grammar) ? [] : [Symbol(symbol)]
    end

    results = []
    for production in grammar[symbol]
        combinations = []
        for part in production
            push!(combinations, generate_candidates_from_cfg(grammar, part, max_depth - 1))
        end
        for combination in Iterators.product(combinations...)
            if length(production) == 1
                push!(results, combination[1])
            else
                push!(results, Expr(:call, combination...))
            end
        end
   end

   return results
end

function generate_candidates_from_primitives(dsl::DSL, arguments::Vector{String}, max_depth::Int)
    # Vector{Any}[] instead of []
    depth_exprs = [[] for _ in 0:max_depth]

    # Initialize depth 0 set with arguments and 0-arity primitives
    depth_exprs[1] = [Symbol(arg) for arg in arguments]
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
                    new_expr = Expr(:call, Symbol(primitive.name), arg_combination...)
                    push!(depth_exprs[d+1], new_expr)
                end
            end
        end
        @debug depth_exprs[d]
    end
    # Return the union of all such expressions
    return vcat(depth_exprs...)
end


function evaluate_candidates(candidates, dsl::DSL, examples)
    scores = Dict()
    for candidate in candidates
        scores[candidate] = 0
        for example in examples
            inputs, output = example
            if evaluate(candidate, dsl, inputs) == output
                scores[candidate] += 1
            end
        end
    end
    return scores
end

function evaluate_candidates_meta(candidates, dsl::DSL, examples)
    scores = Dict()
    for candidate in candidates
        scores[candidate] = 0
        for example in examples
            inputs, output = example
            if evaluate_meta(candidate, dsl, inputs) == output
                scores[candidate] += 1
            end
        end
    end
    return scores
end

function search_noOE(
    config::Dict{String},
    dsl::DSL, 
    examples, 
    arguments::Vector{String}, 
    max_depth::Int
    )

    if config["cfg"]
        dsl.grammar["CONST"] = [[k] for k in arguments]
        candidates = generate_candidates_from_cfg(dsl.grammar, "PROG", max_depth)
    else
        candidates = generate_candidates_from_primitives(dsl, arguments, max_depth)
    end

    @debug println(candidates)
    
    if config["meta"]
        scores = evaluate_candidates_meta(candidates, dsl, examples)
    else
        scores = evaluate_candidates(candidates, dsl, examples)
    end

    best_candidate = argmax(scores)
    return best_candidate
end