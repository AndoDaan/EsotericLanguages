--  http://esolangs.org/wiki/Puzzlang
--  http://esolangs.org/wiki/User:AndoDaan

--  This is a Puzzlang interpreter implemented in Lua (have the latest version installed for the best results).
--  To run this script, from your commandline:
--
--		lua InPuzzlang.lua [puzzlang script] [bf output file]
--
--  the bf out file is optiona. If ommited, InPuzzlang handle the produced bf code and run just like any other
--  bf interpreter. If included, InPuzzlang will forgo that to just instead writing the bf code to the file you
--  gave.

pFileName=arg[1]

function interpretBrainFuckCode(mcode)

	-- Brainfuck interpreter in Lua. Taken from the public domain. Naxunum of 5000 memory cells, 256 bits, cells
	-- and dp both wrapping.

	local code = mcode
	local ip = 1
	local dp = 1
	local mem = {0}
	local codelen = string.len(code)

	local commands =
	{
		add = string.byte("+"),
		sub = string.byte("-"),
		next = string.byte(">"),
		prev = string.byte("<"),
		startloop = string.byte("["),
		endloop = string.byte("]"),
		input = string.byte(","),
		output = string.byte(".")
	}

	while ip <= codelen do
		local cmd = string.byte(code, ip)
		if cmd == commands.add then
			mem[dp] = mem[dp] + 1
			if mem[dp] == 256 then mem[dp] = 0 end
		elseif cmd == commands.sub then
			mem[dp] = mem[dp] - 1
			if mem[dp] == -1 then mem[dp] = 255 end
		elseif cmd == commands.next then
			dp = dp + 1
			if dp>5000 then dp=0 end
			if mem[dp] == nil then mem[dp] = 0 end
		elseif cmd == commands.prev then
			dp = dp - 1
			if dp == 0 then dp=5000 end
			if mem[dp]==nil then mem[dp] = 0 end
		elseif cmd == commands.input then
			local entry = io.stdin:read(1)
			if entry == nil then
				mem[dp] = 0 -- end of file
			else
				entry = string.byte(entry)
				if entry > 255 then entry = 255
				elseif entry < 0 then entry = 0 end
				mem[dp] = entry
			end
		elseif cmd == commands.output then
			io.stdout:write(string.char(mem[dp]))
		elseif cmd == commands.startloop and mem[dp] == 0 then
			local descent = 1
			repeat
				ip = ip + 1
				if ip > codelen then
					print("Unmatched [")
					os.exit(1)
				end
				cmd = string.byte(code, ip)
				if cmd == commands.startloop then descent = descent + 1
				elseif cmd == commands.endloop then descent = descent - 1 end
			until descent == 0
		elseif cmd == commands.endloop and mem[dp] ~= 0 then
			local descent = 1
			repeat
				ip = ip - 1
				if ip == 0 then
					print("Unmatched ]")
					os.exit(1)
				end
				cmd = string.byte(code, ip)
				if cmd == commands.endloop then descent = descent + 1
				elseif cmd == commands.startloop then descent = descent - 1 end
			until descent == 0
		end
		ip = ip + 1
	end
end

function PuzzlangToBrainfuck(s)
	local List="  X>X  <XXX+   - X .X X,XX [ XX]"
	if type(s)=="string" and #s==3 then
		tStr=List:match(s..'[><%+%-.,%[%]]')
		return tStr:sub(-1)
	else
		return nil, "NOT A VALID PUZZLANG INSTRUCTION"
	end
end


function fileToBrainFuck(pFileName)
	local pFile=io.open(pFileName,"r")
	local tLines={}
	local largest=0

	for line in pFile:lines() do
		striped= string.gsub(line,'[^X]', ' ') -- Any non 'X' charactr is treated as ' '
		table.insert(tLines,striped)
		if largest<#striped then largest=#striped end
	end
	pFile:close()
	local last=tLines[#tLines] table.insert(tLines,1,last)
	local outBrainFuck=""

	for l=2,#tLines do
		oLine=tLines[l-1]
		if #oLine<largest then oLine=oLine..string.rep(' ',largest-#oLine) end
		iLine=tLines[l]
		if #iLine<largest then iLine=iLine..string.rep(' ',largest-#iLine) end

		for x=1,#iLine do
			if iLine:sub(x,x)=='X' then
				local n1=x-1>0 and x-1 or largest
				local n3=x+1<=largest and x+1 or 1
				local n=x

				nnn=string.sub(oLine,n1,n1)..string.sub(oLine,n,n)..string.sub(oLine,n3,n3)
				outBrainFuck=outBrainFuck..PuzzlangToBrainfuck(nnn)
			end
		end
	end

	return outBrainFuck
end

bfCode=fileToBrainFuck(pFileName)
io.close()
if arg[2]~=nil then

	bFileName=arg[2]
	bFile=io.open(bFileName,"w+")
	bFile:write(bfCode)
	bFile:close()
	print("\nbrainfuck code writen to "..bFileName)
else
	print()
	print('  running puzzlang/brainfuck code:')
	print()
	print('  '..bfCode)
	print()
	interpretBrainFuckCode(bfCode)
end
print()print('  end of program')
