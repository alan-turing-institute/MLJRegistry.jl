## MLJRegistry

A package registry for the Julia machine learning framework
[MLJ](https://github.com/alan-turing-institute/MLJ.jl).

[Models in registered packages](Models.toml)

[Model metadata](Metadata.toml)

Any Julia machine learning model that implements the MLJ interface is
immediately available for use by MLJ. However, models in
*registered* packages are discoverable by all MLJ users - whether or not the packages have been imported - through MLJ's
task interface.

[![Build
Status](https://travis-ci.com/alan-turing-institute/MLJRegistry.jl.svg?branch=master)](https://travis-ci.com/alan-turing-institute/MLJRegistry.jl)


### Background

MLJ is a Julia framework for combining and tuning machine learning
models. To implement a model see the instructions in the MLJ document
["Implementing the MLJ interface for a learning
algorithm"](https://github.com/alan-turing-institute/MLJ.jl/blob/master/doc/adding_new_models.md),
and the [MLJ repo](https://github.com/alan-turing-institute/MLJ.jl)
for more on MLJ.


### How to register a package

For now, new packages can be registered by creating an issue on this repository.

