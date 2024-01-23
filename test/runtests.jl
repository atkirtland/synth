using Test
using Logging
# Logging.global_logger(SimpleLogger(stdout, Logging.Debug))

using synth

@testset "Program Synthesizer Tests" begin
    include("tests.jl")
end