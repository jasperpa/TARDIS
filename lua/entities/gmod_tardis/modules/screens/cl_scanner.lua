-- Scanner

local mat = CreateMaterial(
	"UnlitGeneric",
	"GMODScreenspace",
	{
		["$basetexturetransform"] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
		["$texturealpha"] = "0",
		["$vertexalpha"] = "1",
	}
)

ENT.scannerres=1

local uid=0
ENT:AddScreen("Scanner", function(self,frame,screen)
	for i=0.1,2,0.1 do -- autodetects maximum resolution
		if (self.screenx*i<=ScrW()) or (self.screeny*i<=ScrH()) then
			self.scannerres=i
		else
			break
		end
	end
	screen.scanner=GetRenderTarget("tardisi_scanner-"..uid.."-"..screen.id,
		self.screenx*self.scannerres,
		self.screeny*self.scannerres,
		false
	)
	uid=uid+1
	screen.scannerang=Angle()
	
	local scanner=vgui.Create("DImage",frame)
	scanner:SetSize(frame:GetWide()-self.screengap2,frame:GetTall()-self.screengap2)
	scanner:SetPos(self.screengap,self.screengap)
	scanner:SetMaterial(mat)
	scanner.OldPaint=scanner.Paint
	scanner.Paint=function()
		mat:SetTexture( "$basetexture", screen.scanner )
		scanner:OldPaint()
	end
	
	local label = vgui.Create("DLabel",frame)
	label:SetFont("TARDIS-Med")
	label.DoLayout = function()
		label:SizeToContents()
		label:SetPos(frame:GetWide()/2-label:GetWide()/2-self.screengap,frame:GetTall()-label:GetTall()-self.screengap)
	end
	label:SetText("Front")
	label:DoLayout()
	
	local function updatetext(y)
		local text
		if y==-180 or y==180 then
			text="Back"
		elseif y==-90 then
			text="Right"
		elseif y==0 then
			text="Front"
		elseif y==90 then
			text="Left"
		end
		label:SetText(text)
		label:DoLayout()
	end
	
	local back=vgui.Create("DButton",frame)
	back:SetSize(frame:GetTall()*0.2-self.screengap,frame:GetTall()*0.15-self.screengap)
	back:SetPos(self.screengap+1,frame:GetTall()-back:GetTall()-self.screengap-1)
	back:SetText("<")
	back:SetFont("TARDIS-Default")
	back.DoClick = function()
		screen.scannerang.y=screen.scannerang.y+90
		if screen.scannerang.y>=180 then
			screen.scannerang.y=-180
		end
		updatetext(screen.scannerang.y)
	end
	
	local nxt=vgui.Create("DButton",frame)
	nxt:SetSize(frame:GetTall()*0.2-self.screengap,frame:GetTall()*0.15-self.screengap)
	nxt:SetPos(frame:GetWide()-nxt:GetWide()-self.screengap-1,frame:GetTall()-nxt:GetTall()-self.screengap-1)
	nxt:SetText(">")
	nxt:SetFont("TARDIS-Default")
	nxt.DoClick = function()
		screen.scannerang.y=screen.scannerang.y-90
		if screen.scannerang.y<=-180 then
			screen.scannerang.y=180
		end
		updatetext(screen.scannerang.y)
	end
end)

hook.Add("RenderScene", "TARDISI_Scanner", function(pos,ang)
	local int=LocalPlayer():GetTardisData("interior")
	local ext=LocalPlayer():GetTardisData("exterior")
	if IsValid(ext) then
		local screens=ext:ScreenActive("Scanner")
		if screens then
			for k,v in pairs(screens) do
				local oldRT = render.GetRenderTarget()
				render.SetRenderTarget( v.scanner )
					render.Clear( 0, 0, 0, 255 )
					render.ClearDepth()
					render.ClearStencil()
					
					local vec=Vector(22,0,50)
					vec:Rotate(v.scannerang)
					local camOrigin = ext:LocalToWorld(vec)
					local camAngle = ext:LocalToWorldAngles(v.scannerang)
					if IsValid(int) then
						int.scannerrender=true
					end
					render.RenderView({
						x = 0,
						y = 0,
						w = ext.screenx*ext.scannerres,
						h = ext.screeny*ext.scannerres,
						fov = 120,
						origin = camOrigin,
						angles = camAngle,
						drawpostprocess = true,
						drawhud = false,
						drawmonitors = false,
						drawviewmodel = false,
						--zfar = 1500
					})
					if IsValid(int) then
						int.scannerrender=false
					end
				render.SetRenderTarget( oldRT )
			end
		end
	end
end)