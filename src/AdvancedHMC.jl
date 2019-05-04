module AdvancedHMC

const DEBUG = Bool(parse(Int, get(ENV, "DEBUG_AHMC", "0")))

using Statistics: mean, var, middle
using LinearAlgebra: Symmetric, UpperTriangular, mul!, ldiv!, dot, I, diag, cholesky
using LazyArrays: BroadcastArray
using Random: GLOBAL_RNG, AbstractRNG

import StatsBase: sample

# Notations
# d - dimension of sampling sapce
# π(θ) - target distribution
# r - momentum variable

include("adaptation/Adaptation.jl")
export UnitEuclideanMetric, DiagEuclideanMetric, DenseEuclideanMetric
export NesterovDualAveraging, Preconditioner, NaiveCompAdaptor, StanNUTSAdaptor
using .Adaptation

include("hamiltonian.jl")
export Hamiltonian
include("integrator.jl")
export Leapfrog
include("trajectory.jl")
export StaticTrajectory, find_good_eps, HMCDA, NUTS

include("diagnosis.jl")
include("sampler.jl")
export sample

end # module