# synth

A program synthesizer in Julia, with the eventual goal of synthesizing parts of OO-MDPs

## TODO

- [x] basic enumerative PBE given a DSL: 2023-08
- [x] observational equivalence with bottom-up enumeration: 2024-01-25
- [x] consider symmetry of commutative operations: 2024-01-28 changed tests to be example-based
- [ ] options for bottom-up and top-down search
- [ ] recursion (?)
- [ ] add code for OO-MDP environments
- [ ] add DSL for OO-MDPs

## Usage

```
$ julia
julia> ]
(@v1.9) pkg> activate .
(synth) pkg> test
```
