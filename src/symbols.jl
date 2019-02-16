import Base: length

using Printf: @sprintf

export @Morse

"""
MorseUnits are the basic building block of Morse code.
They serve as code units for MorseStrings.

Users should not create new instances of MorseUnit intsances, but rather reference the predfined constants for each of the 2 marks and 3 gaps.
"""
abstract type MorseUnit end
MorseUnit(c::AbstractChar) = c == ' ' ? MorseGap(c) : MorseMark(c)
function MorseUnit(s::AbstractString)
    occursin(r"^ *$", s) && return MorseGap(s)
    @assert length(s) == 1 "Invalid MorseUnit representation."
    return MorseMark(s[1])
end

"""
Each unit is mainly characterized by its length.
It is given in integer multiple of a dit's length.
"""
length(unit::MorseUnit) = unit.length

"There are two Morse marks: The short (. or dit) and the long (- or dah) one."
struct MorseMark <: MorseUnit
    length::UInt8
end
const dit = MorseMark(1)
const dah = MorseMark(3)

function MorseMark(mark::AbstractChar)
    if mark == '.' || mark == '·'
        return dit
    elseif mark == '-' || mark == '−'
        return dah
    end
    error(@sprintf "Invalid Morse mark representation '%c'." mark)
end

# length(m::MorseMark) = m.length

"There are three Morse gaps: The short one as mark separator, the medium one as character and signal separator, and the long one as word separator."
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
    error(@sprintf "Invalid Morse gap representation \"%s\"." gap)
end
function MorseGap(gap::AbstractChar)
    if gap == ' '
        return cgap
    end
    error(@sprintf "Invalid Morse gap representation '%c'." gap)
end

# length(g::MorseGap) = g.length

"""
The MorseCode type is an alias for a Vector of Morse units.
It comes with a convenience constructor to turn a string of . and - into Morse code.
"""
const MorseCode = Vector{<: MorseUnit}
MorseCode(code::AbstractString=""; strict::Bool=false) = MorseUnit[MorseUnit(m.match) for m = eachmatch(strict ? r"(?<!^| )(?! |$)| +|[^ ]" : r" +|[^ ]", code)]

"These macros can be used to insert single Morse marks or Morse code."
macro Morse(mark::AbstractChar)
    m = MorseUnit(mark)
    return :($m)
end
macro Morse(code::AbstractString)
    c = MorseCode(code)
    return :($c)
end
