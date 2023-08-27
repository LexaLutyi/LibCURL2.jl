using Pkg
cd(@__DIR__)
Pkg.activate("gen")
Pkg.update()

include("gen/generate.jl")

Pkg.activate("..")
Pkg.update()
Pkg.test()