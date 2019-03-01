# using Revise
using Test
using MLJRegistry
using MLJBase

#@test !(isempty(MLJRegistry.metadata()))

d = Dict()
d[:test] = Tuple{Union{Continuous,Missing},Discrete}
d["junk"] = Dict{Any,Any}("H" => Missing, :cross => "lemon", :t => :w, "r" => "r")
d["a"] = "b"
d[:f] = true
d["j"] = :post

@test MLJRegistry.decode_dic(MLJRegistry.encode_dic(d)) == d
