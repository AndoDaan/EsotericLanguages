--Interpreter for the joke esoteric language Verbose
--(Verbose createdd by: http://esolangs.org/wiki/User:Poolala)
--http://esolangs.org/wiki/Verbose#Hello.2C_world.21

--written by: http://esolangs.org/wiki/User:AndoDaan

--If you copy this file by transcribing it
--key by key, you can do what you like with the fruit
--of your labour.

--To run "lua inVerbose.lua inputfile"

local function isRoman(str)
	if string.sub(str,1,1)=="-" then str = string.sub(str,2,-1)  end

	if string.match(str, "[^IVXLCDM]")~=nil then return false else return true end
end

local function DecimalToRoman(number)
	local roman, sign ="",""
	if number==0 then return "NULLA" end
	if number < 0 then number = math.abs(number) sign="-" end
	if number > 3999 then print("NUMBER IS TOO BIG") return nil end
	while number > 999 do
		roman = roman .. "M"
		number = number - 1000
	end
	while number >899 do
		roman = roman .. "CM"
		number = number - 900
	end
	while number > 499 do
		roman = roman .. "D"
		number = number - 500
	end
	while number > 399 do
		roman = roman .. "CD"
		number = number - 400
	end
	while number > 99 do
		roman = roman .. "C"
		number = number - 100
	end
	while number > 89 do
		roman = roman .. "XC"
		number = number - 90
	end
	while number > 49 do
		roman = roman .. "L"
		number = number - 50

	end
	while number > 39 do
		roman = roman .. "XL"
		number = number - 40

	end
	while number > 9 do
		roman = roman .. "X"
		number = number - 10

	end
	while number > 8 do
		roman = roman .. "IX"
		number = number - 9

	end
	while number > 4 do
		roman = roman .. "V"
		number = number - 5

	end
	while number > 3 do
		roman = roman .. "IV"
		number = number - 4

	end
	while number > 0 do
		roman = roman .. "I"
		number = number - 1

	end
	return sign .. roman
end

local function RomanToDecimal(str2)
	local cLetter,lLetter
	local sum = 0
	local str = str2
	local l = #str2
	local sign
	local lValues = {}

	lValues["I"]=1 lValues["V"]=5 lValues["X"]=10 lValues["L"]=50 lValues["C"]=100 lValues["D"]=500 lValues["M"]=1000

	if str == "NULLA" then return 0 end
	if string.sub(str2,1,1)=="-" then sign = -1 str=string.sub(str2,2) l = l-1 else sign = 1 end
	if string.match(str, "[^IVXLCDM]")~=nil then return false, "Not a valid roman numeral" end

	for i=l,1,-1 do
		cLetter=string.sub(str,i,i)
		if lLetter==nil then
			lLetter = cLetter
			sum = sum + lValues[cLetter]
		else
			if lValues[cLetter]<lValues[lLetter] then
				sum = sum - lValues[cLetter]
			else
				sum = sum + lValues[cLetter]
			end
			lLetter = cLetter
		end
	end
	return sum*sign
end

local function instruction(str, stack, index)
	if string.match(str, "PUT THE NUMBER .* ONTO THE TOP OF THE PROGRAM STACK") then
		local roman = string.gsub(str, "PUT THE NUMBER (.*) ONTO THE TOP OF THE PROGRAM STACK", "%1")

		if isRoman(roman)== true then
			local number = RomanToDecimal(roman)
			table.insert(stack, 1, number)
			return stack
		else
			print("Error ---")
			return nil
		end
	elseif str=="REMOVE THE CURRENT ELEMENT OF THE PROGRAM STACK" then
		table.remove(stack, 1)
		return stack
	elseif str=="GET THE FIRST ELEMENT OF THE PROGRAM STACK AND DUPLICATE IT AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local number = stack[1]
		table.insert(stack,1,number)
		return stack
	elseif str=="MOVE THE FIRST ELEMENT OF THE PROGRAM STACK TO THE SECOND ELEMENT'S PLACE AND THE SECOND ELEMENT OF THE STACK TO THE FIRST ELEMENT'S PLACE" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, number1)
		table.insert(stack, 1, number2)
		return stack
	elseif str=="ADD THE FIRST ELEMENT OF THE PROGRAM STACK AND THE SECOND ELEMENT OF THE PROGRAM STACK TOGETHER AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, number1+number2)
		return stack
	elseif str=="SUBTRACT THE SECOND ELEMENT OF THE PROGRAM STACK FROM THE FIRST ELEMENT OF THE PROGRAM STACK AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, number1-number2)
		return stack
	elseif str=="MULTIPLY THE FIRST ELEMENT OF THE PROGRAM STACK BY THE SECOND ELEMENT OF THE PROGRAM STACK AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, number1*number2)
		return stack
	elseif str=="DIVIDE THE FIRST ELEMENT OF THE PROGRAM STACK BY THE SECOND ELEMENT OF THE PROGRAM STACK AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, math.floor(number1/number2))
		return stack
	elseif str=="DIVIDE THE FIRST ELEMENT OF THE PROGRAM STACK BY THE SECOND ELEMENT OF THE PROGRAM STACK AND GET THE REMAINDER AND PUT THE REMAINDER ONTO THE TOP OF THE PROGRAM STACK" then
		local number1, number2 = stack[1], stack[2]

		table.insert(stack, 1, number1%number2)
		return stack
	elseif str=="GET THE FIRST ELEMENT OF THE PROGRAM STACK AND THE SECOND ELEMENT OF THE PROGRAM STACK AND IF THE SECOND ELEMENT OF THE PROGRAM STACK IS NOT ZERO JUMP TO THE INSTRUCTION THAT IS THE CURRENT INSTRUCTION NUMBER AND THE FIRST ELEMENT ADDED TOGETHER'S RESULT" then
		if stack[2]~=0 then
			index = stack[1]
			return stack, index
		end
		return stack
	elseif str=="GET A CHARACTER TYPED IN BY THE CURRENT PERSON USING THIS PROGRAM AND GET THE CHARACTER'S ASCII CODE AND PUT THE RESULT ONTO THE TOP OF THE PROGRAM STACK" then
		local character
		io.stdin:flush()
		io.stdout:flush()
		character = io.stdin:read(1)
		local ascii = string.byte(character)
		table.insert(stack, 1, ascii)
		return stack
	elseif str=="GET A ROMAN NUMERAL TYPED IN BY THE CURRENT PERSON USING THIS PROGRAM AND PUT IT ONTO THE TOP OF THE PROGRAM STACK" then
		local romanInput = io.stdin:read("*l")
		if isRoman(romanInput) then
			table.insert(stack, 1, RomanToDecimal(romanInput))
			return stack
		else
			print("Input is not a valid roman numeral")
			return stack
		end
	elseif str=="GET THE TOP ELEMENT OF THE STACK AND CONVERT IT TO AN ASCII CHARACTER AND OUTPUT IT FOR THE CURRENT PERSON USING THIS PROGRAM TO SEE" then
		local number = stack[1]
		io.stdout:write(string.char(number))
		return stack
	elseif str=="GET THE TOP ELEMENT OF THE STACK AND OUTPUT IT FOR THE CURRENT PERSON USING THIS PROGRAM TO SEE" then
		local number = stack[1]
		print(DecimalToRoman(number))
		return stack
	else
		print("ERROR - not a valid instruction")
		return stack
	end
end

local inst = {}
local cStack = {}
local cInstruction = 1
local pFileName=arg[1]
file = io.open(pFileName, "r")
io.input(file)

for line in io.lines() do
	table.insert(inst, line)
end
io.close(file)
repeat
	cStack, cIndex = instruction(inst[cInstruction], cStack, cInstruction)
	if cIndex == nil then cInstruction = cInstruction +1 else cInstruction = cInstruction + cIndex cIndex = nil end
until cInstruction > #inst
