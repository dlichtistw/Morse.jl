import Base: codeunit, ncodeunits
import Base: isvalid, getindex
import Base: iterate
import Base: Generator

using Printf: @sprintf

export MorseString, code, @Morse_str

"""
A MorseString consists simply of a Morse code.
"""
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

"The Morse macro can be used to write a MorseString in . and -."
macro Morse_str(code::String)
    s = MorseString(MorseCode(code))
    return :($s)
end

"Return the MorseString's code as MorseCode object."
code(s::MorseString) = s.code

"Allows access to single code units."
codeunit(s::MorseString, i::Integer) = s.code[i]
codeunit(::MorseString) = MorseUnit

"Count the number of individual code units in a string."
ncodeunits(s::MorseString) = lastindex(s.code)

"""
Determine whether a given index is valid to extract single code groups.

An index is valid if
    1. it is a mark in first position or preceded by a medium or long gap.
    2. it is a long gap.
Otherwise, it is invalid.
"""
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

"""
Determine the index of the last code unit belonging to the group pointed to by the given index.
This is either
    1. the same index in case of a long gap.
    2. the last index for the last group in the code.
    3. the index before the next medium or long gap.
"""
function _findGroupEnd(code::MorseCode, i::Integer)
    code[i] == wgap && return i
    e = findfirst(code[i:end]) do s
        return s == cgap || s == wgap
    end
    e isa Nothing && return lastindex(code)
    return i + e - 2
end

"""
Return the MorseGroup of which the encoding starts at the given index.
If no group begins at that index, it is invalid and an error is thrown.
"""
function getindex(s::MorseString, i::Integer)
    !(1 ≤ i ≤ lastindex(s)) && error(@sprintf "Index out of bounds: %d" i)
    isvalid(s, i) && return MorseGroup(s.code[i:_findGroupEnd(s.code, i)])
    error(@sprintf "Invalid index: %d" i)
end

"Iterate over the MorseGroups of a MorseString."
iterate(s::MorseString, i::Integer=1) = 1 ≤ i ≤ lastindex(s) ? (s[i], nextind(s, i)) : nothing
