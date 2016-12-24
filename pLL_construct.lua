function construct()
	if fs.expand("$(SEQ)")=="" then
		if fs.expand("$(PLAN)")=="" then
			local    win01 = ui.titlewindow ("Which Shot")
			-- the control function builds a named parent window and a control inside, so there is no name clash
			local	function control (title, name, parent, plug)
			  local frame = ui.window (name, parent)
			  local text = ui.text ("text", frame)
			  text:settext (title)
			  text:setpos { x= 0, y = 0, w=50, h=ui.full }
			  local control = ui.control (frame, plug)
			  control:setpos { x=50, y=0}
			  return frame, control
			end
			local    myString = Plug (win01, "Sequence", Plug.NoSerial, types.string, "SEQUENCE")
			local    stringframe, stringcontrol = control ("SEQ", "myStringCtrl", win01, myString)
			stringframe:setpos { y=ui.top,w=200, h=25 }
			local    myString2 = Plug (win01, "Sequence2", Plug.NoSerial, types.string, "PLAN")
			local    stringframe2, stringcontrol2 = control ("PLAN", "myStringCtrl2", win01, myString2)
			stringframe2:setpos { y=26,w=200, h=25 }
			local    button = ui.textbutton ("button", win01, "Click")
			function button:buttonclicked ()
				if myString:get()=="SEQUENCE" then
					print("From is not change")
				elseif myString2:get()=="PLAN" then
					print("To is not change")
				else
				local	Preferences = getpreferences ()
				local	projectEnv = Preferences.ProjectEnvironment:get()
				local	var1="SEQ="..myString:get()
				local	var2="PLAN="..myString2:get()
				projectEnv=projectEnv.."\n"..var1.."\n"..var2
				Preferences.ProjectEnvironment:set(projectEnv)
				win01:hide()
				scanProject()
				end
			end
			button:setpos { w=50, h=15, y=ui.bottom }

			win01:setpos { w=225, h=75 }
			win01:show ()
		else
		scanProject()
		end
	else
	scanProject()
	end
end
--method of splitting string by pattern
function split(pString, pPattern)
	   local	Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	   local	fpat = "(.-)" .. pPattern
	   local	last_end = 1
	   local	s, e, cap = pString:find(fpat, 1)
	   while s do
		  if s ~= 1 or cap ~= "" then
		 table.insert(Table,cap)
		  end
		  last_end = e+1
		  s, e, cap = pString:find(fpat, last_end)
	   end
	   if last_end <= #pString then
		  cap = pString:sub(last_end)
		  table.insert(Table, cap)
	   end
	   return Table
end
function listImport(path)
	--List the reference file found in the path
	local l=1
	local list={}
	local pathList={}
	for filename, stat in fs.dir (path,{"%.gproject:reg","%.abc:reg"}) do
		list[l]=filename
		pathList[l]=path.."/"..filename
		l=l+1
	end
	if list[1]==nil then
		print("no asset founded")
	else
		--Create a window listing the file found in the folder
		local	win03 = ui.titlewindow ("File founded")
		local	myboo02={}
		local	function control02(title,name,parent,j)
			local frame = ui.window (name, parent)
			local text = ui.text ("text", frame)
			text:settext (title)
			text:setpos { x=0, y=0, w=50, h=ui.full }
			myboo02[j] = Plug (frame, "MyBool"..tostring(j), Plug.NoSerial, types.bool, false)
			-- create a control (which will be a checkbox) on MyBool
			local checkboxcontrol = ui.control (frame,myboo02[j])
			checkboxcontrol:setpos { x=250, y=0}
			return frame
		end
		local	height=1
		for i,value in ipairs(list) do
			local nameString="file"..tostring(i)
			local foundedFiles=control02(value,nameString,win03,i)
			foundedFiles:setpos { y=ui.top+(i-1)*25,w=700, h=25 }
			height=i
		end
		local    button02 = ui.textbutton ("button", win03, "Click")
		function button02:buttonclicked ()
			for m, value in ipairs(myboo02) do
				if myboo02[m]:get()==true then
					local mod = Document:modify ()
					local	assetName=split(list[m],"%.")
					mod.createref(assetName[1],path.."/"..list[m],nil)
					mod.finish ()
				else
				end
				savedocument(nil,true)
			end
			win03:destroy()
		end
		button02:setpos { w=50, h=15, y=ui.bottom }
		win03:setpos { w=750, h=height*25 }
		win03:show ()
		return myboo02
	end
end
function scanProject()
	--animation cache
	local	pathHoudini = "$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/HOUDINI/MASTER/CACHEFILES"
	local	pathMax = "$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/MAX/MASTER/CACHEFILES"
	local	pathMaya = "$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/MAYA/MASTER/CACHEFILES"
	--shading reference
	local	pathDecors = "$(PROJET_PR)/DATA/LIB/BANQUE/DECORS/MASTER/SCENES"
	local	pathSetup = "$(PROJET_PR)/DATA/LIB/BANQUE/SETUP/MASTER/SCENES"
	listImport(pathHoudini)
	listImport(pathMax)
	listImport(pathMaya)
	listImport(pathDecors)
	listImport(pathSetup)
	--Set The projet output folder and save the project
	local outputPath = "$(PROJET_PR)/OUT/RENDER/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/"
	local mod=Document:modify()
	mod.deletenode(_"RenderPass")
	Document:loadfile("D:/ISART_PROJECT_MANAGER/GUERILLA/plugins/renderPassPR.glayer")
	mod.finish()
	for child in children (Document, "RenderPass") do
		child.FileName:set (outputPath..fs.expand("S$(SEQ)P$(PLAN)").."$l_$n_$o_$e_$05f.$x")
		child.DisplayDriver:set("exr")
		child.Depth:set("half")
		child.Gamma:set(1)
	end
	fs.mkdir("$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/GUERILLA/")
	fs.mkdir("$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/GUERILLA/SCENES/")	
	savedocument ("$(PROJET_PR)/DATA/FILM/S$(SEQ)/S$(SEQ)P$(PLAN)/GUERILLA/SCENES/"..fs.expand("S$(SEQ)P$(PLAN).gproject"),true,false)
end