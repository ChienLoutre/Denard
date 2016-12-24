function searchNReplace(from,target)
	local mod=Document:modify()
	local function stringPathReplace(stringPath,from,target)
		local newPath=stringPath
		newPath=string.gsub(newPath,"\/","\\")
		newPath=string.gsub(newPath,from,target)
		return newPath
	end
	for child in children (Document, "Primitive",nil,true) do
		local ghostDataPath = child.GeometryPath:get ()
		ghostDataPath=stringPathReplace(ghostDataPath,from,target)
		child.GeometryPath:set(ghostDataPath)
	end
	for child in children (Document, "Reference",nil,true) do
		local ghostDataPath = child.ReferenceFileName:get ()
		ghostDataPath=stringPathReplace(ghostDataPath,from,target)
		child.ReferenceFileName:set(ghostDataPath)
	end
	for node in children (Document, "ShaderNodeTexture", nil, true) do
		local fileNameTexture=node.Filename:get ()
		fileNameTexture=stringPathReplace(fileNameTexture,from,target)
		node.Filename:set(fileNameTexture)
	end
	local acceptedShader = { Texture = true, MaskTexture = true,NormalMap = true }
	local function checkTexture (node)
		local shader = node.Shader and node.Shader:get ()
		return acceptedShader[shader]
	end
	for attr in children (Document, "AttributeShader", checkTexture, true) do
		local fileNameTexture=attr.File:get ()
		fileNameTexture=stringPathReplace(fileNameTexture,from,target)
		attr.File:set(fileNameTexture)
	end
	for child in children (Document, "Yeti",nil,true) do
		local yetiNodePath = child.File:get()
		yetiNodePath=stringPathReplace(yetiNodePath,from,target)
		child.File:set(yetiNodePath)
	end
	for child in children (Document, "Light",nil,true) do
		local lightMapPath=child.LightMap:get()
		lightMapPath=stringPathReplace(lightMapPath,from,target)
		child.LightMap:set(lightMapPath)
	end
	for child in children (Document,"EnvironmentLocator",nil,true) do
		local lightMapPath=child.EnvironmentMap:get()
		lightMapPath=stringPathReplace(lightMapPath,from,target)
		child.EnvironmentMap:set(lightMapPath)
	end
	mod.finish()
end