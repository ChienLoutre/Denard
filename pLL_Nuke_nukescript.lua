local guerillaNukeScript = command.create("Menus|Nuke|Nuke Script")
function guerillaNukeScript:action()
	require("pLL_nukeScript")
	guke()
end
if MainMenu then
	MainMenu:addcommand(guerillaNukeScript,"Nuke")
end