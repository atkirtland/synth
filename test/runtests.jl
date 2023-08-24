using Test
using Logging
# Logging.global_logger(SimpleLogger(stdout, Logging.Debug))

using synth

# Run Tests
@testset "Program Synthesizer Tests" begin
    include("tests.jl")
end