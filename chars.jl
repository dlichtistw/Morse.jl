import Base: codepoint, show

using Base: InvalidCharError
using Printf: @sprintf

export code

abstract type MorseGroup <: AbstractChar end
function MorseGroup(code::MorseCode)
	haskey(CharCodeDict, code) && return CharCodeDict[code]
	haskey(SignalCodeDict, code) && return SignalCodeDict[code]
	error("Unrecognized Morse code.")
end
MorseGroup(cp::Integer) = MorseChar(cp)
MorseGroup(char::AbstractChar) = MorseChar(char)
MorseGroup(name::AbstractString) = MorseSignal(name)

struct MorseChar <: MorseGroup
    code::MorseCode
    cp::UInt32

    function MorseChar(code::MorseCode, cp::UInt32)
        @assert length(code) > 0 "A MorseChar's code must be nonempty."
        @assert all((u isa MorseMark for u = code)) || code == [wgap] "A MorseChar's code must be composed of only marks or consist of a single word gap."
        mc = new(copy(code), cp)
        CharCodeDict[mc.code] = mc
        CharPointDict[mc.cp] = mc
        return mc
    end
end
function MorseChar(cp::Integer)
    haskey(CharPointDict, cp) && return CharPointDict[cp]
    error(@sprintf "Invalid codepoint %d for MorseChar conversion." cp)
end
MorseChar(char::AbstractChar) = MorseChar(codepoint(char))
function MorseChar(code::MorseCode)
	haskey(CharCodeDict, code) && return CharCodeDict[code]
	error("Invalid Morse code for MorseChar conversion.")
end
MorseChar(code::String) = MorseChar(MorseCode(code))
macro MorseChar(marks::String, char::Char)
	code = MorseCode(marks)
	cp = codepoint(char)
	return :(MorseChar($code, $cp))
end

const CharCodeDict = Dict{MorseCode, MorseChar}()
const CharPointDict = Dict{UInt32, MorseChar}()

codepoint(mc::MorseChar) = mc.cp

code(mc::MorseChar) = mc.code

struct MorseSignal <: MorseGroup
	code::MorseCode
	name::String
	meaning::String

	function MorseSignal(code::MorseCode, name::AbstractString, meaning::AbstractString)
		@assert length(code) > 0 "A MorseSignal's code must be nonempty."
        @assert all((u isa MorseMark for u = code)) || code == [wgap] "A MorseSignal's code must be composed of only marks or consist of a single word gap."
        ms = new(copy(code), name, meaning)
        SignalCodeDict[ms.code] = ms
		SignalNameDict[ms.name] = ms
        return ms
    end
	MorseSignal(code::MorseCode, name::AbstractString) = MorseSignal(code, name, name)
end
function MorseSignal(code::MorseCode)
	haskey(SignalCodeDict, code) && return SignalCodeDict[code]
	error("Invalid code for MorseSignal conversion.")
end
function MorseSignal(name::AbstractString)
	haskey(SignalNameDict, name) && return SignalNameDict[name]
	error(@sprintf "Unknown Morse signal name \"%s\"." name)
end
macro MorseSignal(marks::AbstractString, name::AbstractString, meaning::AbstractString)
	code = MorseCode(marks)
	return :(MorseSignal($code, $name, $meaning))
end
macro MorseSignal(marks::AbstractString, name::AbstractString)
	code = MorseCode(marks)
	return :(MorseSignal($code, $name, $name))
end

const SignalCodeDict = Dict{MorseCode, MorseSignal}()
const SignalNameDict = Dict{String, MorseSignal}()

code(ms::MorseSignal) = ms.code

show(io::IO, ::MIME"text/plain", signal::MorseSignal) = write(io, @sprintf "MorseSignal(\"%s\")" signal.name)

# ITU-R M.1677-1 code list:

@MorseChar "  " ' '
@MorseChar ".-" 'A'
@MorseChar "-..." 'B'
@MorseChar "-.-." 'C'
@MorseChar "-.." 'D'
@MorseChar "." 'E'
@MorseChar "..-." 'F'
@MorseChar "--." 'G'
@MorseChar "...." 'H'
@MorseChar ".." 'I'
@MorseChar ".---" 'J'
@MorseChar "-.-" 'K'
@MorseChar ".-.." 'L'
@MorseChar "--" 'M'
@MorseChar "-." 'N'
@MorseChar "---" 'O'
@MorseChar ".--." 'P'
@MorseChar "--.-" 'Q'
@MorseChar ".-." 'R'
@MorseChar "..." 'S'
@MorseChar "-" 'T'
@MorseChar "..-" 'U'
@MorseChar "...-" 'V'
@MorseChar ".--" 'W'
@MorseChar "-..-" 'X'
@MorseChar "-.--" 'Y'
@MorseChar "--.." 'Z'
@MorseChar ".----" '1'
@MorseChar "..---" '2'
@MorseChar "...--" '3'
@MorseChar "....-" '4'
@MorseChar "....." '5'
@MorseChar "-...." '6'
@MorseChar "--..." '7'
@MorseChar "---.." '8'
@MorseChar "----." '9'
@MorseChar "-----" '0'
@MorseChar ".--.-" 'À'
@MorseChar ".-.-" 'Ä'
@MorseChar ".-..-" 'È'
@MorseChar "..-.." 'É'
@MorseChar "---." 'Ö'
@MorseChar "..--" 'Ü'
@MorseChar "...--.." 'ß'
@MorseChar "--.--" 'Ñ'
@MorseChar ".-.-.-" '.'
@MorseChar "--..--" ','
@MorseChar "---..." ':'
@MorseChar "..--.." '?'
@MorseChar ".----." '\''
@MorseChar "-....-" '-'
@MorseChar "-..-." '/'
@MorseChar "-.--." '('
@MorseChar "-.--.-" ')'
@MorseChar ".-..-." ')'
@MorseChar "-...-" '='
@MorseChar ".-.-." '+'
@MorseChar "-..-" '*'
@MorseChar ".--.-." '@'

@MorseSignal  "...-." "VE" "Understood"
@MorseSignal "........" "HH" "Error"
@MorseSignal "-.-" "K" "Invitation to transmit"
@MorseSignal ".-..." "AI" "Wait"
@MorseSignal "...-.-" "SK" "End of work"
@MorseSignal "-.-.-" "KA" "Starting signal"
