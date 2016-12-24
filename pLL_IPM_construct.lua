local	shotConstruct = command.create ("Menus|IPM|construct")
function shotConstruct:action ()
	require("pLL_construct")
	construct()
end
if MainMenu then
	MainMenu:addcommand (shotConstruct, "IPM")
end