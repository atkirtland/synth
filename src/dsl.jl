struct Primitive
    name::String
    func::Function
    arity::Int
end

struct DSL
    grammar::Dict{String, Vector{Vector{String}}}
    primitives::Vector{Primitive}
end

function add_primitive!(dsl::DSL, name::String, func::Function, arity::Int)
    push!(dsl.primitives, Primitive(name, func, arity))
end

function get_primitive(dsl::DSL, name::String)
    for primitive in dsl.primitives
        if primitive.name == name
            return primitive
        end
    end
    error("Primitive function $name not found in DSL")
end

function get_primitive_arity(dsl::DSL, name::String)
    for primitive in dsl.primitives
        if primitive.name == name
            return primitive.arity
        end
    end
    error("Primitive function $name not found in DSL")
end

# example DSL
function create_example_dsl()
    grammar = Dict(
        "PROG" => [["EXPR"]],
        "EXPR" => [["CONST"], ["OP2", "EXPR", "EXPR"]],
        "OP2" => [["add"], ["subtract"], ["multiply"]],
    )
    # dsl = DSL([])
    dsl = DSL(grammar, [])

    # below are same
    # add_primitive!(dsl, "add", (a,b) -> a + b, 2)
    # add_primitive!(dsl, "subtract", (a,b)->a-b, 2)
    # add_primitive!(dsl, "multiply", (a,b)->a*b, 2)
    add_primitive!(dsl, "add", +, 2)
    add_primitive!(dsl, "subtract", -, 2)
    add_primitive!(dsl, "multiply", *, 2)

    return dsl
end
