using Test
using MLJRegistry

@test !(isempty(metadata()))
@test !(isempty(models()))


