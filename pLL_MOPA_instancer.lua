--Instancer Guerilla need a selected element to work.
local	guerillaIns = command.create ("Menus|MOPA|Instancer")

function instancerRun(instanceName)
	local mod=Document:modify()
	local s = Document:getselection ()
	local refName
	if s then
		for k, node in pairs (s) do
			refName=node
		end
	end
	for child in children (Document, "SceneGraphNode",instanceName) do
		mod.adddependency(child.Instances,refName.Instances)
	end
	mod.finish()
end

function guerillaIns:action()
	-- create a title window
    local    win = ui.titlewindow ("Instance Name")
	
	-- the control function builds a named parent window and a control inside, so there is no name clash
	   local	function control (title, name, parent, plug)
		  local frame = ui.window (name, parent)
		  local text = ui.text ("text", frame)
		  text:settext (title)
		  text:setpos { x= 0, y = 0, w=50, h=ui.full }
		  local control = ui.control (frame, plug)
		  control:setpos { x=50, y=0, w=ui.full-50, h=ui.full }
		  return frame, control
	   end
	
	local    myString = Plug (win, "Sequence", Plug.NoSerial, types.string, "Instance")
    local    stringframe, stringcontrol = control ("From", "myStringCtrl", win, myString)
    stringframe:setpos { y=ui.top,w=200, h=25 }
	
	local    button = ui.textbutton ("button", win, "Click")
	function button:buttonclicked ()
		if myString:get()=="Instance" then
				print("From is not change")
		else
			instancerRun(myString:get())
		end
	end
	
	
	win:setpos { w=225, h=75 }
    win:show ()
	
end
if MainMenu then
	MainMenu:addcommand (guerillaIns, "MOPA")
end