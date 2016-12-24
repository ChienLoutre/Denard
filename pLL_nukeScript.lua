--This script create a nuke project script at the gproject Path V0.1.3 2016/11/07
-----------------------------------------------------------------------------------------------------
--Nuke base nodes
instr = [[#! C:/Program Files/Nuke10.0v3/nuke-10.0.3.dll -nx
version 10.0 v3
define_window_layout_xml {<?xml version="1.0" encoding="UTF-8"?>
<layout version="1.0">
    <window x="0" y="0" w="1920" h="1156" screen="0">
        <splitter orientation="1">
            <split size="40"/>
            <dock id="" hideTitles="1" activePageId="Toolbar.1">
                <page id="Toolbar.1"/>
            </dock>
            <split size="1249" stretch="1"/>
            <splitter orientation="2">
                <split size="647"/>
                <dock id="" activePageId="Viewer.1">
                    <page id="Viewer.1"/>
                </dock>
                <split size="455"/>
                <dock id="" activePageId="DAG.1" focus="true">
                    <page id="DAG.1"/>
                    <page id="Curve Editor.1"/>
                    <page id="DopeSheet.1"/>
                </dock>
            </splitter>
            <split size="615"/>
            <dock id="" activePageId="Properties.1">
                <page id="Properties.1"/>
            </dock>
        </splitter>
    </window>
</layout>
}
Root {
 inputs 0
 first_frame FIRST_GR_FRAME
 last_frame LAST_GR_FRAME
 format "ROOT_FORMAT"
 proxy_type scale
 proxy_format "1024 778 0 0 1024 778 1 1K_Super_35(full-ap)"
 colorManagement Nuke
}
Viewer {
 inputs 0
 frame 1
 frame_range 1-100
 name Viewer1
 xpos 0
 ypos 200
}
]]
--Nuke empty reader slot
readStr = [[READ_DRIVER {
 inputs 0
 file "FILE_PATH"
 format "FILE_FORMAT"
 first FIRST_GR_FRAME
 last LAST_GR_FRAME
 origfirst FIRST_GR_FRAME
 origlast LAST_GR_FRAME
 origset true
 on_error "nearest frame"
 name READ_NAME
 xpos READ_XPOS
 ypos READ_YPOS
}
]]
backdropStr = [[BackdropNode {
 inputs 0
 name BACKDROP_NAME
 tile_color 0xffHEXACOLOR
 label BACK_LABEL
 note_font_size 42
 xpos BACK_XPOS
 ypos -100
 bdwidth BACK_WIDTH
 bdheight 200
}
]]
---------------------------------------------------------------------------------------------------
local beautyAOV = { Diffuse = true, IndDiffuse = true, Specular = true, Reflection = true, SSS = true, Refraction = true, Incandescence = true }
local nukeTable = {}
--see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end
--convert a decimal value in an hexadecimal
function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789abcdef","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end
--function split string
function split(pString, pPattern)
       local    Table = {}  -- NOTE: use {n = 0} in Lua-5.0
       local    fpat = "(.-)" .. pPattern
       local    last_end = 1
       local    s, e, cap = pString:find(fpat, 1)
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
--generate a random hexadecimal RVB code
function HEX_RNDM()
    return DEC_HEX(math.random()*16777215)
end

function getRootFormat()
    local rootFormat = tostring(_".ProjectWidth":get()).." "..tostring(_".ProjectHeight":get()).." 0 0 "..tostring(_".ProjectWidth":get()).." "..tostring(_".ProjectHeight":get()).." "..tostring(_".ProjectAspectRatio":get()).." projectFormat"
    return rootFormat
end
--test if AOV exist in a table 
local function search(master, target) --target is a string
    for k,v in next, master do
        if type(v)=="table" and v[target] then return true end
    end
end
--call read node text and replace the value
function createReadBeauty(i,j,value,readName,Driver)
    local readStrTMP = readStr
    readStrTMP = readStrTMP:gsub("READ_DRIVER",Driver)
    readStrTMP = readStrTMP:gsub("READ_NAME",readName)
    readStrTMP = readStrTMP:gsub("FILE_PATH",value)
    readStrTMP = readStrTMP:gsub("FILE_FORMAT",getRootFormat())
    readStrTMP = readStrTMP:gsub("READ_XPOS",(i*200)+(j*200))
    readStrTMP = readStrTMP:gsub("READ_YPOS","0")
    readStrTMP = readStrTMP:gsub("FIRST_GR_FRAME",_".FirstFrame":get())
    readStrTMP = readStrTMP:gsub("LAST_GR_FRAME",_".LastFrame":get())
    nukeTable[#nukeTable+1]=readStrTMP
end

--create backdrop node
function createBackdrop(backDropName,a,i,j)
    local backdropStrTMP = backdropStr
    backdropStrTMP = backdropStrTMP:gsub("BACKDROP_NAME",backDropName)
    backdropStrTMP = backdropStrTMP:gsub("BACK_XPOS",((i-a)*200)+(j*200))
    backdropStrTMP = backdropStrTMP:gsub("BACK_WIDTH",((a)*200))
    backdropStrTMP = backdropStrTMP:gsub("HEXACOLOR",HEX_RNDM())
    backdropStrTMP = backdropStrTMP:gsub("BACK_LABEL",backDropName)
    table.insert(nukeTable,3,backdropStrTMP)
end


function fileDriver(DriverDisplay)
    if DriverDisplay=="exrid" then
        return "exr"
    else
        return DriverDisplay
    end
end
--list all aov in the current scene and write the nuke script
function guke()
    nukeTable = {}
    local outFile = fs.expand("$(SCENE_PATH)").."\\"..fs.expand("$(SCENE)")..".nk"

    instr = instr:gsub("ROOT_FORMAT",getRootFormat())
    instr = instr:gsub("FIRST_GR_FRAME",_".FirstFrame":get())
    instr = instr:gsub("LAST_GR_FRAME",_".LastFrame":get())
    nukeTable[1]=instr

    local listReadPath={}
    local i=0
    local j=0

    for renderpass in children (Document, "RenderPass", nil, true) do
        local path = renderpass.FileName:get()
        path = fs.expand(path):gsub("\\","\/")
        path = path:gsub("wip","images")
        local fileEx = fileDriver(renderpass.DisplayDriver:get ())
        renderpass.Width:get ()
        renderpass.Height:get ()
        local multichannelLayer = path:find("$n")
        if multichannelLayer~=nil then
            print(true)
            for layer in children (renderpass, "RenderLayer") do
                local a = 0
                for AOV in children(layer,"LayerOut") do
                    if AOV.OverrideSettings:get()==false then
                        listReadPath[i]=string.gformat(path,{ l = renderpass:getname (), n = layer:getname (),o = AOV.PlugName:get (), e = 1,x = fileEx, f = "#####" })
                    else
                        if AOV.FileName:get()~="" then
                            listReadPath[i]=AOV.FileName:get()
                        else
                            listReadPath[i]=string.gformat(path,{ l = renderpass:getname (), n = layer:getname (),o = AOV.PlugName:get (), e = 1, f= "#####" })
                        end
                        listReadPath[i]=string.gformat(listReadPath[i],{ x = fileDriver(AOV.DisplayDriver:get ())})
                    end
                    local value = listReadPath[i]
                    local readName = layer:getname ().."_"..AOV.PlugName:get ()
                    if renderpass.DisplayDriver:get ()=="exrid" and AOV.OverrideSettings:get()==false then
                        createReadBeauty(i,j,value,readName,"DeepRead")
                    elseif AOV.DisplayDriver:get ()=="exrid" and AOV.OverrideSettings:get()==true then
                        createReadBeauty(i,j,value,readName,"DeepRead")
                    else
                        createReadBeauty(i,j,value,readName,"Read")
                    end
                    print(AOV.PlugName:get(),renderpass.DisplayDriver:get (),AOV.OverrideSettings:get(),AOV.DisplayDriver:get ())
                    i = i+1
                    a = a +1
                end
                local backDropName =  layer:getname ()
                createBackdrop(backDropName,a,i,j)
                j = j +1 
            end
         else
            local newPath = string.gformat(path,{ l = renderpass:getname (), e = 1,x = fileEx, f = "#####" })
            local nameReadMulti = path:gsub("$e","")
            nameReadMulti = nameReadMulti:gsub("$f","")
            nameReadMulti = nameReadMulti:gsub("$x","")
            local pathParsed = split(nameReadMulti,"/")
            table.getn(pathParsed)
            createReadBeauty(i,j,newPath,pathParsed[table.getn(pathParsed)],"Read")
        end
    end
    local outfile = io.open(outFile, "w")
    outfile:write(table.concat(nukeTable))
    outfile:close()
end