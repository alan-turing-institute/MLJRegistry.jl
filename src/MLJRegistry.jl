module MLJRegistry

export metadata, models

import TOML

const srcdir = dirname(@__FILE__) # the directory containing this file

# for changing symbols to strings in dictionaries:
encode(s) = s isa Symbol ? string(":", s) : s
encode(v::Vector) = encode.(v)
function encode(d::Dict)
    ret = Dict{}()
    for (k, v) in d
        ret[encode(k)] = encode(v)
    end
    return ret
end

# for changing strings to symbols in dictionaries:
decode(s) =
    s isa String && !isempty(s) && s[1] == ':' ? Symbol(s[2:end]) : s
decode(v::Vector) = decode.(v)
function decode(d::Dict)
    ret = Dict()
    for (k, v) in d
        ret[decode(k)] = decode(v)
    end
    return ret
end

# TODO: make these OS independent (../ not working on windows?)
metadata() = TOML.parsefile(joinpath(srcdir, "../", "Metadata.toml")) |> decode
models() = TOML.parsefile(joinpath(srcdir, "../", "Models.toml")) |> decode

end # module
