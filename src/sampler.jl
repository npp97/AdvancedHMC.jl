function logα(H::Real, H_new::Real)
    return min(0, H - H_new)
end

function is_accept(logα::Real)
    return log(rand()) < logα
end

function sample(h::Hamiltonian, p::AbstractProposal, θ::AbstractVector{T}, n_samples::Int) where {T<:Real}
    θs = Vector{Vector{T}}(undef, n_samples)
    Hs = Vector{T}(undef, n_samples)
    αs = Vector{T}(undef, n_samples)
    time = @elapsed for i = 1:n_samples
        θs[i], Hs[i], αs[i] = step(h, p, i == 1 ? θ : θs[i-1])
    end
    @info "Finished sampling with $time (s)" typeof(h) typeof(p) EBFMI(Hs) mean(αs)
    return θs
end

function step(rng::AbstractRNG, h::Hamiltonian, prop::TakeLastProposal{I}, θ::AbstractVector{T}) where {T<:Real,I<:AbstractIntegrator}
    r = rand_momentum(rng, h)
    _H = hamiltonian_energy(h, θ, r)
    θ_new, r_new = propose(prop, h, θ, r)
    _H_new = hamiltonian_energy(h, θ_new, r_new)
    # Accept via MH criteria
    _logα = logα(_H, _H_new)
    α = exp(_logα)
    if !is_accept(_logα)
        return θ, _H, α
    end
    return θ_new, _H_new, α
end

function step(rng::AbstractRNG, h::Hamiltonian, prop::SliceNUTS{I}, θ::AbstractVector{T}) where {T<:Real,I<:AbstractIntegrator}
    r = rand_momentum(rng, h)
    _H = hamiltonian_energy(h, θ, r)
    θ_new, r_new = propose(rng, prop, h, θ, r)
    _H_new = hamiltonian_energy(h, θ_new, r_new)
    # We always accept in NUTS
    return θ_new, _H_new, one(T)
end

step(h::Hamiltonian, p::AbstractProposal, θ::AbstractVector{T}) where {T<:Real} = step(GLOBAL_RNG, h, p, θ)