import Base: display, length

using Printf: @sprintf

export @Morse

abstract type MorseUnit end
MorseUnit(c::AbstractChar) = c == ' ' ? MorseGap(c) : MorseMark(c)
function MorseUnit(s::AbstractString)
    occursin(r"^ *$", s) && return MorseGap(s)
    @assert length(s) == 1 "Invalid MorseUnit representation."
    return MorseMark(s[1])
end

struct MorseMark <: MorseUnit
    length::UInt8
end
const dit = MorseMark(1)
const dah = MorseMark(3)

function MorseMark(mark::AbstractChar)
    if mark == '.'
        return dit
    elseif mark == '-'
        return dah
    end
    throw(DomainError(@sprintf("'%s'", mark), "Valid MorseMark representations are '.' and '-'."))
end

length(m::MorseMark) = m.length

struct MorseGap <: MorseUnit
    length::UInt8
end
const sgap = MorseGap(1)
const cgap = MorseGap(3)
const wgap = MorseGap(7)

function MorseGap(gap::AbstractString)
    if occursin(r"^ *$", gap)
        l = length(gap)
        if l == 0
            return sgap
        elseif l == 1
            return cgap
        elseif l == 2
            return wgap
        end
    end
    throw(DomainError(@sprintf("\"%s\"", gap), "Valid MorseGap representations are 1, 2 or 3 spaces."))
end
function MorseGap(gap::AbstractChar)
    if gap == ' '
        return cgap
    end
    throw(DomainError(@sprintf("'%s'", gap), "Only ' ' is a valid MorseGap representation."))
end

length(g::MorseGap) = g.length

const MorseCode = Vector{<: MorseUnit}
MorseCode(code::AbstractString; strict::Bool=false) = [MorseUnit(m.match) for m = eachmatch(strict ? r"(?<!^| )(?! |$)| +|[^ ]" : r" +|[^ ]", code)]

macro Morse(mark::AbstractChar)
    m = MorseUnit(mark)
    return :($m)
end
macro Morse(code::AbstractString)
    c = MorseCode(code)
    return :($c)
end
