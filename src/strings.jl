import Base: codeunit, ncodeunits
import Base: isvalid, getindex
import Base: iterate
import Base: Generator

using Printf: @sprintf

export MorseString, code, @Morse_str

struct MorseString <: AbstractString
    code::MorseCode
end
MorseString(string::AbstractString; strict::Bool=false) = MorseString((MorseChar(c) for c = string), strict=strict)
function MorseString(groups::Union{Generator{<: Any, Type{G}}, AbstractVector{G}}; strict::Bool=false) where {G <: MorseGroup}
    mc = MorseCode()
    for gr = groups
        gr != MorseChar(' ') && length(mc) > 0 && !(mc[end] isa MorseGap) && push!(mc, cgap)
        append!(mc, code(gr, strict=strict))
    end
    return MorseString(mc)
end

macro Morse_str(code::String)
    s = MorseString(MorseCode(code))
    return :($s)
end

code(s::MorseString) = s.code

codeunit(s::MorseString, i::Integer) = s.code[i]
codeunit(::MorseString) = MorseUnit

ncodeunits(s::MorseString) = lastindex(s.code)

function isvalid(s::MorseString, i::Integer)
    !(1 ≤ i ≤ lastindex(s.code)) && return false
    if s.code[i] == dit || s.code[i] == dah
        i == 1 && return true
        (s.code[i - 1] == cgap || s.code[i - 1] == wgap) && return true
        return false
    elseif s.code[i] == wgap
        return true
    else
        return false
    end
end

function _findGroupEnd(code::MorseCode, i::Integer)
    code[i] == wgap && return i
    e = findfirst(code[i:end]) do s
        return s == cgap || s == wgap
    end
    e isa Nothing && return lastindex(code)
    return i + e - 2
end

function getindex(s::MorseString, i::Integer)
    !(1 ≤ i ≤ lastindex(s)) && error(@sprintf "Index out of bounds: %d" i)
    isvalid(s, i) && return MorseGroup(s.code[i:_findGroupEnd(s.code, i)])
    error(@sprintf "Invalid index: %d" i)
end

iterate(s::MorseString, i::Integer=1) = 1 ≤ i ≤ lastindex(s) ? (s[i], nextind(s, i)) : nothing
