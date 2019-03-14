module MLJRegistry

export @update

import TOML
using InteractiveUtils

# for testings decoding of metadata:
import MLJBase: Found, Continuous, Discrete, OrderedFactor
import MLJBase: FiniteOrderedFactor, Count, Multiclass, Binary

const srcdir = dirname(@__FILE__) # the directory containing this file


## METHODS TO WRITE THE METADATA TO THE ARCHIVE

# for encoding metadata:
function encode_dic(s)
    if s isa Symbol
        return string(":", s)
    elseif s isa AbstractString
        return string(s)
    else
        return string("`", s, "`")
    end
end
encode_dic(v::Vector) = encode_dic.(v)
function encode_dic(d::Dict)
    ret = Dict{}()
    for (k, v) in d
        ret[encode_dic(k)] = encode_dic(v)
    end
    return ret
end

# for decoding metadata:
function decode_dic(s::String)
    if !isempty(s)
        if  s[1] == ':'
            return Symbol(s[2:end])
        elseif s[1] == '`'
            return eval(Meta.parse(s[2:end-1]))
        else
            return s
        end
    else
        return ""
    end
end
decode_dic(v::Vector) = decode_dic.(v)
function decode_dic(d::Dict)
    ret = Dict()
    for (k, v) in d
        ret[decode_dic(k)] = decode_dic(v)
    end
    return ret
end

# TODO: make these OS independent (../ not working on windows?)
# metadata() = TOML.parsefile(joinpath(srcdir, "../", "Metadata.toml")) |> decode_dic


## METHODS TO GENERATE METADATA AND WRITE TO ARCHIVE

function finaltypes(T::Type)
    s = InteractiveUtils.subtypes(T)
    if isempty(s)
        return [T, ]
    else
        return reduce(vcat, [finaltypes(S) for S in s])
    end
end

const project_toml = joinpath(srcdir, "../Project.toml")
const packages = map(Symbol, keys(TOML.parsefile(project_toml)["deps"])|>collect)
filter!(packages) do pkg
    !(pkg in [:TOML, :MLJ, :MLJBase, :MLJModels, :InteractiveUtils])
end
println("Packages to be searched for model implementations:")
println(packages)

const package_import_commands =  [:(import $pkg) for pkg in packages]

macro update()

    program = quote
        
        import MLJBase
        import MLJModels
        import TOML

        # import the packages
        $(MLJRegistry.package_import_commands...)

        modeltypes = MLJRegistry.finaltypes(MLJBase.Model)
        
        # generate and write to file the model metadata:
        packages = string.(MLJRegistry.packages)
        meta_given_package = Dict()
        for pkg in packages
            meta_given_package[pkg] = Dict()
        end
        for M in modeltypes
            _info = MLJBase.info(M)
            pkg       = _info[:package_name]
            if pkg != "unknown"
                modelname = _info[:name]
                meta_given_package[pkg][modelname] = _info
            end
        end
        open(joinpath(MLJRegistry.srcdir, "../Metadata.toml"), "w") do file
            TOML.print(file, MLJRegistry.encode_dic(meta_given_package))
        end
        
        # generate and write to file list of models for each package:
        models_given_pkg = Dict()
        for pkg in packages
            models_given_pkg[pkg] = collect(keys(meta_given_package[pkg]))
        end
        open(joinpath(MLJRegistry.srcdir, "../Models.toml"), "w") do file
            TOML.print(file, models_given_pkg)
        end
    end
    __module__.eval(program)
    :(println("Local Metadata.toml updated."))
end

end # module
