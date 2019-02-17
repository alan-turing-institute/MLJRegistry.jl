module MLJRegistry

import TOML
using InteractiveUtils

const srcdir = dirname(@__FILE__) # the directory containing this file


## METHODS TO ACCESS THE METADATA FROM ARCHIVE

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


## METHODS TO GENERATE METADATA AND WRITE TO ARCHIVE

function finaltypes(T::Type)
    s = InteractiveUtils.subtypes(T)
    if isempty(s)
        return [T, ]
    else
        return reduce(vcat, [finaltypes(S) for S in s])
    end
end

const bar = :(import MLJBase)

macro foo()
    program = quote
        $bar
        println(MLJBase.Model)
    end
    __module__.eval(program)
    quote end
end

const project_toml = joinpath(srcdir, "../Project.toml")
const packages = map(Symbol, keys(TOML.parsefile(project_toml)["deps"])|>collect)
filter!(packages) do pkg
    !(pkg in [:TOML, :MLJ, :MLJBase, :MLJModels, :InteractiveUtils])
end
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
            TOML.print(file, MLJRegistry.encode(meta_given_package))
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
    "Done"
end

end # module
