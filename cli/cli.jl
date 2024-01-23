using ArgParse

using synth

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--meta"
        help = "use evaluate_candidates_meta instead of evaluate_candidates"
        action = :store_true
        "--cfg"
        help = "use CFG based generation instead of arity/primitives"
        arg_type = Bool
        default = true
        "--max_depth"
        help = "maximum depth of generated programs"
        arg_type = Int
        default = 5
    end

    return parse_args(s)
end

function main()
    args = parse_commandline()
    println(args)
end

main()