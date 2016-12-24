local	guerillaSNR = command.create ("Menus|MOPA|searchNreplace")
function guerillaSNR:action ()
	-- create a title window
    local    win = ui.titlewindow ("searchNreplace")

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

    local    myString = Plug (win, "Sequence", Plug.NoSerial, types.string, "From")
    local    stringframe, stringcontrol = control ("From", "myStringCtrl", win, myString)
    stringframe:setpos { y=ui.top,w=200, h=25 }
    local    myString2 = Plug (win, "Sequence2", Plug.NoSerial, types.string, "To")
    local    stringframe2, stringcontrol2 = control ("To", "myStringCtrl2", win, myString2)
    stringframe2:setpos { y=26,w=200, h=25 }
    local    button = ui.textbutton ("button", win, "Click")
    function button:buttonclicked ()
        require("pLL_searchNReplace")
		searchNReplace(myString:get(),myString2:get())
    end
    button:setpos { w=50, h=15, y=ui.bottom }

    win:setpos { w=225, h=75 }
    win:show ()
end
if MainMenu then
	MainMenu:addcommand (guerillaSNR, "MOPA")
end
