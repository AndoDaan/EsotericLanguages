#!/usr/bin/lua

--MNNBFSL Interpreter
--Visit https://github.com/yshl/MNNBFSL for more info on MNNBFSL

local function pInfo()
	odStack='Data Stack: '
	orStack='Return Stack: '
	if #dStack>0 then
		for i=1,#dStack do
			odStack=odStack..i..':'..dStack[i]..' '
		end
	else
		odStack=odStack..'nil'
	end

	if #rStack>0 then
		for	i=1,#rStack do
			orStack=orStack..i..':'..rStack[i]..' '
		end
	else
		orStack=orStack..'nil'
	end

	print('iPointer: '..iPointer, 'cInstruction '..cInstruction)
	print()
	print(odStack)
	print(orStack)
	print()
	print('>>'..output)
	print()
end

local function err(msg)
	pInfo()
	print(msg)
    os.exit(0)
end

local function parseCode(s)
	s=s:gsub('[^%"%[%]%+%-%<%>%,%.s]',' ')
	count=0
	for i in s:gmatch('.') do
		iTape[count]=i
		count=count+1
	end

	return s
end

local function step()
	if iPointer>#iTape then
		print('>>'..output)
		print('End of Program')
		os.exit(0)
	end

	cInstruction = iTape[iPointer]

	if cInstruction=='"' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			temp=dStack[1]+0
			table.insert(dStack,1,temp)
		end
	elseif cInstruction=='+' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			dStack[1]=dStack[1]+1
		end
	elseif cInstruction=='-' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			dStack[1]=dStack[1]-1
		end
	elseif cInstruction=='>' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			temp=dStack[1]+0
			table.remove(dStack,1)
			table.insert(rStack,1, temp)
		end
	elseif cInstruction=='<' then
		if rStack[1]==nil then
			err('rStack underflow')
		else
			temp=rStack[1]+0
			table.remove(rStack,1)
			table.insert(dStack,1,temp)
		end
	elseif cInstruction=='[' then
		table.insert(rStack,1,iPointer-0)
	elseif cInstruction==']' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			temp=dStack[1]+0
			table.remove(dStack,1)
			if temp==0 then
				table.remove(rStack,1)
			else
				if  rStack[1]==nil then
					err('rStack underflow')
				else
					iPointer=rStack[1]-1
					table.remove(rStack,1)
				end
			end
		end
	elseif cInstruction=='.' then
		if dStack[1]==nil then
			err('dStack underflow')
		else
			temp=dStack[1]+0
			table.remove(dStack,1)
			output=output..string.char(temp)
		end
	elseif cInstruction==',' then

		if iMode=='fInput' and input~='' then
			temp=input:sub(1,1)
			input=input:sub(2,-1)
			table.insert(dStack,1,string.byte(temp))
		elseif iMode=='stdin' then
			iChar=io.read(1)
			table.insert(dStack,1,iChar..'')
		end
		if input=='' then
			table.insert(dStack,1,0)
			iMode='eof'
		else
			table.insert(dStack,1,1)
		end
	elseif cInstruction=='s' then
		pInfo()
	end
	iPointer=iPointer+1
end


iTape,dStack,rStack={},{},{}
iPointer=0
output,input,iMode='','',''
code=''

if arg[1]=='-h' or arg[1]=='-help' or arg[1]=='?' or arg[1]=='?' or arg[1]==nil then
	print('Run by:')
	print('','lua [BFSL code file] [-stdin or -file] [input file]')
	os.exit()
end

local pFileName=arg[1] pFileName=string.lower(pFileName)

if pFileName==nil then
	print('No Input File Given')
	os.exit()
else
	local pFile=io.open(pFileName,"r")
	code=pFile:read('*a')
	pFile:close()
	parseCode(code)
end

if arg[2]==nil or arg[2]=="-stdin" then
	iMode = 'stdin'
elseif arg[2]=="-file" then
	iFileName=arg[3]
	if iFileName==nil then
		iMode='eof'
		input=''
	else
		iFile=io.open(iFileName,"r")
		input=iFile:read('*a')
		if #input > 0 and input~=nil then
			iMode='fInput'
		else
			iMode='eof'
		end
		iFile:close()
	end
elseif string.gmatch(arg[2],'".+"') then
	input = string.sub(arg[2],2,-2)
end

while''do
	step()
end
