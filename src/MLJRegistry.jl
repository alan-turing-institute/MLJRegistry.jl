module MLJRegistry

export metadata, models

import TOML

const srcdir = dirname(@__FILE__) # the directory containing this file:

# TODO: make these OS independent (../ not working on windows?)
metadata() = TOML.parsefile(joinpath(srcdir, "../", "Metadata.toml"))
models() = TOML.parsefile(joinpath(srcdir, "../", "Models.toml"))

end # module
