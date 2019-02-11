# using Revise
using Test
using MLJRegistry

@test !(isempty(metadata()))
@test !(isempty(models()))

d = Dict()
d[:test] = "junk"
d["junk"] = Dict{Any,Any}("H" => :fever, :cross => "lemon", :t => :w, "r" => "r")
d["a"] = "b"
d[:f] = :k
d["j"] = :post

@test MLJRegistry.decode(MLJRegistry.encode(d)) == d
