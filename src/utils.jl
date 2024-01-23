include("dsl.jl")

function evaluate(sym::Symbol, dsl::DSL, inputs::Dict{Symbol, Int64})
    return inputs[sym]
end

function evaluate(expr::Expr, dsl::DSL, inputs::Dict{Symbol, Int64})
    if expr.head == :call
        if expr.args[1] in keys(inputs)
            return inputs[expr.args[1]]
        else
            primitive = get_primitive(dsl, string(expr.args[1]))
            func = primitive.func
            if !isa(func, Function)
                error("Expected a function, but got a $(typeof(func))")
            end
            evaluated_args = [isa(arg, Expr) ? evaluate(arg, dsl, inputs) : inputs[arg] for arg in expr.args[2:end]]
            return func(evaluated_args...)
        end
    else
        error("Unsupported expression type")
    end
end

function evaluate_meta(sym::Symbol, dsl::DSL, inputs::Dict{Symbol, Int64})
    return inputs[sym]
end

function evaluate_meta(expr::Expr, dsl::DSL, inputs::Dict{Symbol, Int64})
    primitive_definitions = Expr(:block)
    for primitive in dsl.primitives
        push!(primitive_definitions.args, :(const $(Symbol(primitive.name)) = $(primitive.func)))
    end

    input_definitions = Expr(:block)
    for (key, value) in inputs
        push!(input_definitions.args, :($key = $(value)))
    end

    complete_expr = Expr(:block, primitive_definitions, input_definitions, expr)

    @debug println(complete_expr)
    return @eval $(complete_expr)
end
