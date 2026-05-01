-- Script: bi | Cổng Dịch Chuyển V2 | LocalScript > StarterPlayerScripts

local P=game:GetService("Players")
local RS=game:GetService("RunService")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local pl=P.LocalPlayer
local ch=pl.Character or pl.CharacterAdded:Wait()
local hrp=ch:WaitForChild("HumanoidRootPart")
pl.CharacterAdded:Connect(function(c) ch=c hrp=c:WaitForChild("HumanoidRootPart") end)

local CA=Color3.fromRGB(0,200,255)
local CB=Color3.fromRGB(255,30,60)
local portals={} -- không giới hạn cổng
local cd=false
local portalCount=0

local fol=workspace:FindFirstChild("BiP") or Instance.new("Folder")
fol.Name="BiP" fol.Parent=workspace

-- =====================
--   TẠO CỔNG
-- =====================
local function mkP(nm,col,pos)
	local p=Instance.new("Part")
	p.Name=nm p.Size=Vector3.new(0.5,8,4)
	p.CFrame=CFrame.new(pos) p.Anchored=true
	p.CanCollide=false p.Material=Enum.Material.Neon
	p.Color=col p.Transparency=0.3 p.Parent=fol

	-- Highlight
	local h=Instance.new("Highlight",p)
	h.FillColor=col h.OutlineColor=col
	h.FillTransparency=0.85 h.OutlineTransparency=0

	-- BillboardGui tên cổng
	local bb=Instance.new("BillboardGui",p)
	bb.Size=UDim2.new(0,140,0,45)
	bb.StudsOffset=Vector3.new(0,6,0) bb.AlwaysOnTop=true
	local lb=Instance.new("TextLabel",bb)
	lb.Size=UDim2.new(1,0,1,0) lb.BackgroundTransparency=1
	lb.Text="⬡ "..nm lb.TextColor3=col lb.TextScaled=true
	lb.Font=Enum.Font.GothamBold lb.TextStrokeTransparency=0

	-- Particle
	local at=Instance.new("Attachment",p)
	local pe=Instance.new("ParticleEmitter",at)
	pe.Color=ColorSequence.new(col) pe.LightEmission=1 pe.Rate=40
	pe.Speed=NumberRange.new(1,6) pe.Lifetime=NumberRange.new(0.4,1.8)
	pe.SpreadAngle=Vector2.new(180,180)
	pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(1,0)})
	pe.Rotation=NumberRange.new(0,360) pe.RotSpeed=NumberRange.new(-90,90)

	-- Hiệu ứng xoay
	local spin=Instance.new("BodyAngularVelocity",p)
	spin.AngularVelocity=Vector3.new(0,0.4,0)
	spin.MaxTorque=Vector3.new(0,1e5,0)

	-- Nhấp nháy
	TS:Create(p,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.65}):Play()

	-- Hiệu ứng xuất hiện (scale từ 0)
	p.Size=Vector3.new(0,0,0)
	TS:Create(p,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=Vector3.new(0.5,8,4)}):Play()

	return p
end

local function rmP(p)
	if not(p and p.Parent) then return end
	local t=TS:Create(p,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=Vector3.new(0,0,0)})
	t:Play() t.Completed:Connect(function() p:Destroy() end)
end

-- =====================
--   FLASH GUI
-- =====================
local fg=Instance.new("ScreenGui",pl.PlayerGui)
fg.Name="BiF" fg.ResetOnSpawn=false fg.IgnoreGuiInset=true
local ff=Instance.new("Frame",fg)
ff.Size=UDim2.new(1,0,1,0) ff.BackgroundTransparency=1
ff.BorderSizePixel=0 ff.ZIndex=100
local function flash(col)
	ff.BackgroundColor3=col ff.BackgroundTransparency=0.2
	TS:Create(ff,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
end

-- =====================
--   TELEPORT
-- =====================
RS.Heartbeat:Connect(function()
	if cd or not(hrp and hrp.Parent) then return end
	if #portals<2 then return end
	local pos=hrp.Position
	for i,pA in ipairs(portals) do
		if not(pA and pA.Parent) then continue end
		if (pos-pA.Position).Magnitude<4 then
			-- Tìm cổng tiếp theo để dịch
			local pB=portals[i%#portals+1]
			if not(pB and pB.Parent) then continue end
			cd=true
			hrp.CFrame=CFrame.new(pB.Position+Vector3.new(0,0,3))
			flash(pB.Color)
			task.wait(1.5) cd=false
			break
		end
	end
end)

-- =====================
--   MENU GUI
-- =====================
local sg=Instance.new("ScreenGui",pl.PlayerGui)
sg.Name="BiM" sg.ResetOnSpawn=false

local function uic(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function uis(p,col,th) local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=th end
local function grad(p,c1,c2,rot)
	local g=Instance.new("UIGradient",p)
	g.Color=ColorSequence.new(c1,c2) g.Rotation=rot or 90
end

-- Nút toggle mở menu
local tb=Instance.new("TextButton",sg)
tb.Size=UDim2.new(0,44,0,44) tb.Position=UDim2.new(0,16,0,16)
tb.BackgroundColor3=Color3.fromRGB(10,20,40)
tb.BorderSizePixel=0 tb.Text="☰"
tb.TextColor3=Color3.fromRGB(0,200,255)
tb.TextSize=22 tb.Font=Enum.Font.GothamBold tb.ZIndex=20
uic(tb,12) uis(tb,Color3.fromRGB(0,150,200),1.5)

-- Hiệu ứng pulse nút toggle
local pulseConn
local function startPulse()
	pulseConn=RS.Heartbeat:Connect(function()
		local t=tick()
		local alpha=(math.sin(t*3)+1)/2
		tb.BackgroundColor3=Color3.fromRGB(
			math.floor(10+alpha*20),
			math.floor(20+alpha*30),
			math.floor(40+alpha*60)
		)
	end)
end
startPulse()

-- Panel chính
local pn=Instance.new("Frame",sg)
pn.Size=UDim2.new(0,230,0,0) -- tinggi 0 untuk animasi
pn.Position=UDim2.new(0,16,0,70)
pn.BackgroundColor3=Color3.fromRGB(8,14,28)
pn.BorderSizePixel=0 pn.ClipsDescendants=true
pn.Visible=false pn.ZIndex=15
uic(pn,14) uis(pn,Color3.fromRGB(0,120,180),1.5)
grad(pn,Color3.fromRGB(8,14,28),Color3.fromRGB(12,22,44),135)

-- Header panel
local header=Instance.new("Frame",pn)
header.Size=UDim2.new(1,0,0,48) header.Position=UDim2.new(0,0,0,0)
header.BackgroundColor3=Color3.fromRGB(0,40,70)
header.BorderSizePixel=0 header.ZIndex=16
uic(header,14)
grad(header,Color3.fromRGB(0,60,100),Color3.fromRGB(0,30,60),90)

local htitle=Instance.new("TextLabel",header)
htitle.Size=UDim2.new(1,-50,1,0) htitle.Position=UDim2.new(0,14,0,0)
htitle.BackgroundTransparency=1 htitle.Text="⬡  BI PORTAL"
htitle.TextColor3=Color3.fromRGB(0,220,255)
htitle.TextSize=15 htitle.Font=Enum.Font.GothamBold
htitle.TextXAlignment=Enum.TextXAlignment.Left htitle.ZIndex=17

-- Nút X đóng menu
local xBtn=Instance.new("TextButton",header)
xBtn.Size=UDim2.new(0,32,0,32) xBtn.Position=UDim2.new(1,-40,0.5,-16)
xBtn.BackgroundColor3=Color3.fromRGB(180,20,40)
xBtn.BorderSizePixel=0 xBtn.Text="✕"
xBtn.TextColor3=Color3.fromRGB(255,255,255)
xBtn.TextSize=14 xBtn.Font=Enum.Font.GothamBold xBtn.ZIndex=18
uic(xBtn,8)

-- Scroll frame cho danh sách cổng
local scroll=Instance.new("ScrollingFrame",pn)
scroll.Size=UDim2.new(1,-16,1,-160) scroll.Position=UDim2.new(0,8,0,56)
scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=Color3.fromRGB(0,180,255)
scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.ZIndex=16

local sll=Instance.new("UIListLayout",scroll)
sll.Padding=UDim.new(0,6) sll.HorizontalAlignment=Enum.HorizontalAlignment.Center
sll.SortOrder=Enum.SortOrder.LayoutOrder

-- Footer nút
local footer=Instance.new("Frame",pn)
footer.Size=UDim2.new(1,0,0,100) footer.Position=UDim2.new(0,0,1,-108)
footer.BackgroundTransparency=1 footer.BorderSizePixel=0 footer.ZIndex=16

local fll=Instance.new("UIListLayout",footer)
fll.Padding=UDim.new(0,7) fll.HorizontalAlignment=Enum.HorizontalAlignment.Center
fll.VerticalAlignment=Enum.VerticalAlignment.Center

local fp=Instance.new("UIPadding",footer)
fp.PaddingLeft=UDim.new(0,10) fp.PaddingRight=UDim.new(0,10)

local function mkB(txt,bg,tc,sc)
	local b=Instance.new("TextButton",footer)
	b.Size=UDim2.new(1,0,0,38) b.BackgroundColor3=bg
	b.BorderSizePixel=0 b.Text=txt b.TextColor3=tc
	b.TextSize=13 b.Font=Enum.Font.GothamBold b.ZIndex=17
	uic(b,9) uis(b,sc,1.5)
	b.MouseButton1Click:Connect(function()
		TS:Create(b,TweenInfo.new(0.08),{Size=UDim2.new(0.95,0,0,38)}):Play()
		task.wait(0.08)
		TS:Create(b,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,38)}):Play()
	end)
	return b
end

local bA=mkB("◉  Tạo Cổng Xanh",Color3.fromRGB(0,35,55),CA,Color3.fromRGB(0,160,210))
local bB=mkB("◉  Tạo Cổng Đỏ",Color3.fromRGB(55,0,18),CB,Color3.fromRGB(200,0,50))

-- Hàm thêm dòng cổng vào scroll
local function addPortalRow(name,col,idx)
	local row=Instance.new("Frame",scroll)
	row.Name="row_"..idx
	row.Size=UDim2.new(1,0,0,38) row.BackgroundColor3=Color3.fromRGB(12,22,42)
	row.BorderSizePixel=0 row.ZIndex=17 row.LayoutOrder=idx
	uic(row,8) uis(row,col,1)

	local dot=Instance.new("Frame",row)
	dot.Size=UDim2.new(0,10,0,10) dot.Position=UDim2.new(0,12,0.5,-5)
	dot.BackgroundColor3=col dot.BorderSizePixel=0
	uic(dot,5)
	-- dot nhấp nháy
	TS:Create(dot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
		{BackgroundTransparency=0.5}):Play()

	local lbl=Instance.new("TextLabel",row)
	lbl.Size=UDim2.new(1,-80,1,0) lbl.Position=UDim2.new(0,30,0,0)
	lbl.BackgroundTransparency=1 lbl.Text=name
	lbl.TextColor3=Color3.fromRGB(200,230,255) lbl.TextSize=12
	lbl.Font=Enum.Font.GothamBold lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.ZIndex=18

	local delBtn=Instance.new("TextButton",row)
	delBtn.Size=UDim2.new(0,30,0,26) delBtn.Position=UDim2.new(1,-38,0.5,-13)
	delBtn.BackgroundColor3=Color3.fromRGB(120,10,25)
	delBtn.BorderSizePixel=0 delBtn.Text="✕"
	delBtn.TextColor3=Color3.fromRGB(255,150,150) delBtn.TextSize=12
	delBtn.Font=Enum.Font.GothamBold delBtn.ZIndex=19
	uic(delBtn,6)

	delBtn.MouseButton1Click:Connect(function()
		rmP(portals[idx])
		portals[idx]=nil
		TS:Create(row,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
		task.wait(0.2) row:Destroy()
	end)

	-- Hiệu ứng xuất hiện row
	row.BackgroundTransparency=1
	TS:Create(row,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundTransparency=0}):Play()

	return row
end

-- Mở/đóng menu với animation
local menuOpen=false
local function openMenu()
	pn.Visible=true
	pn.Size=UDim2.new(0,230,0,0)
	TS:Create(pn,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Size=UDim2.new(0,230,0,340)}):Play()
	tb.Text="✕" tb.TextColor3=Color3.fromRGB(255,80,80)
	menuOpen=true
end

local function closeMenu()
	TS:Create(pn,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),
		{Size=UDim2.new(0,230,0,0)}):Play()
	task.delay(0.3,function() pn.Visible=false end)
	tb.Text="☰" tb.TextColor3=Color3.fromRGB(0,200,255)
	menuOpen=false
end

tb.MouseButton1Click:Connect(function()
	if menuOpen then closeMenu() else openMenu() end
end)
xBtn.MouseButton1Click:Connect(function() closeMenu() end)

-- Kéo menu
local dragging=false
local dragStart,frameStart
pn.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Touch or
	   input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		dragStart=input.Position
		frameStart=pn.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType==Enum.UserInputType.Touch or
	   input.UserInputType==Enum.UserInputType.MouseMove) then
		local delta=input.Position-dragStart
		pn.Position=UDim2.new(
			frameStart.X.Scale,frameStart.X.Offset+delta.X,
			frameStart.Y.Scale,frameStart.Y.Offset+delta.Y
		)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Touch or
	   input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=false
	end
end)

-- Tạo cổng xanh
bA.MouseButton1Click:Connect(function()
	if not hrp then return end
	portalCount=portalCount+1
	local nm="Cổng "..portalCount.." [A]"
	local pos=hrp.Position+hrp.CFrame.LookVector*5
	local p=mkP(nm,CA,pos)
	table.insert(portals,p)
	addPortalRow(nm,CA,#portals)
	closeMenu()
end)

-- Tạo cổng đỏ
bB.MouseButton1Click:Connect(function()
	if not hrp then return end
	portalCount=portalCount+1
	local nm="Cổng "..portalCount.." [B]"
	local pos=hrp.Position+hrp.CFrame.LookVector*5
	local p=mkP(nm,CB,pos)
	table.insert(portals,p)
	addPortalRow(nm,CB,#portals)
	closeMenu()
end)

print("[bi] V2 ready! Không giới hạn cổng!")
