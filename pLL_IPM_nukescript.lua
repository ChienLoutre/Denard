local guerillaNukeScript = command.create("Menus|IPM|Nuke Script")
function guerillaNukeScript:action()
	require("pLL_nukeScript")
	guke()
end
if MainMenu then
	MainMenu:addcommand(guerillaNukeScript,"IPM")
end