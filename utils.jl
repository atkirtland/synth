function evaluate(sym::Symbol, inputs::Dict{Symbol, Int64})
    return inputs[sym]
end

function evaluate(expr::Expr, inputs::Dict{Symbol, Int64})
    if expr.head == :call
        if expr.args[1] in keys(inputs)
            return inputs[expr.args[1]]
        else
            primitive = get_primitive(dsl, string(expr.args[1]))
            func = primitive.func
            if !isa(func, Function)
                error("Expected a function, but got a $(typeof(func))")
            end
            evaluated_args = [isa(arg, Expr) ? evaluate(arg, inputs) : inputs[arg] for arg in expr.args[2:end]]
            return func(evaluated_args...)
        end
    else
        error("Unsupported expression type")
    end
end
