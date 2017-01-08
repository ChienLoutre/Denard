from guerilla import Modifier, Document, Plug, pynode
with Modifier() as mod:
	rR = mod.createnode('Repeat')
	c = mod.createplug(rR,'Repeat','user','vector',Plug.Dynamic,[1,1,0])
	Normal = pynode('RenderGraph|Surface|Normal')
	Normal.Scale.connect(rR.Repeat)
	Diffuse = pynode('RenderGraph|Surface|DiffuseColor')
	Diffuse.Scale.connect(rR.Repeat)
	Spec1 = pynode('RenderGraph|Surface|Spec1Roughness')
	Spec1.connect(rR.Repeat)