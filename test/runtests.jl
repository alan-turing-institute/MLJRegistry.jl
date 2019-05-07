# using Revise
using Test

# brittle hack b/s of https://github.com/dmlc/XGBoost.jl/issues/58:
# using Pkg
# Pkg.add(PackageSpec(url="https://github.com/dmlc/XGBoost.jl"))

using MLJRegistry
using MLJBase

#@test !(isempty(MLJRegistry.metadata()))

d = Dict()
d[:test] = Tuple{Union{Continuous,Missing}, Finite}
d["junk"] = Dict{Any,Any}("H" => Missing, :cross => "lemon", :t => :w, "r" => "r")
d["a"] = "b"
d[:f] = true
d["j"] = :post

@test MLJRegistry.decode_dic(MLJRegistry.encode_dic(d)) == d
