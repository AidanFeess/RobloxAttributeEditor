local toolbar = plugin:CreateToolbar("Attributes Editor")
local Selection = game:GetService("Selection")

local AttributesEditor = toolbar:CreateButton("Edit", "Open the edit menu for the attributes of the selected object", "rbxassetid://7059346373")
AttributesEditor.ClickableWhenViewportHidden = true

local LastSelection = nil
local ObjectLocked = false
local UiPresent = false
local Ui = nil

local defaultPos = UDim2.new(0.031, 0, 0.001, 0)
local yModifier = 55

local attributeObjects = {}

local function CreateUi()
	-- Instances:

	local ScreenGui = Instance.new("ScreenGui")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local Close = Instance.new("TextButton")
	local LockObject = Instance.new("TextButton")
	--Properties:

	ScreenGui.Parent = game.StarterGui

	ScrollingFrame.Parent = ScreenGui
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	ScrollingFrame.BorderColor3 = Color3.fromRGB(29, 29, 29)
	ScrollingFrame.BorderSizePixel = 3
	ScrollingFrame.Position = UDim2.new(0.811240077, 0, 0.120401353, 0)
	ScrollingFrame.Size = UDim2.new(0.149664015, 0, 0.556856215, 0)
	
	Close.Name = "Close"
	Close.Parent = game.StarterGui.ScreenGui
	Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Close.BackgroundTransparency = 1.000
	Close.Position = UDim2.new(0.811240077, 0, 0.120401323, 0)
	Close.Size = UDim2.new(0.0122174714, 0, 0.0334448144, 0)
	Close.Font = Enum.Font.SourceSans
	Close.Text = "X"
	Close.TextColor3 = Color3.fromRGB(170, 0, 0)
	Close.TextScaled = true
	Close.TextSize = 14.000
	Close.TextWrapped = true
	
	LockObject.Name = "LockObject"
	LockObject.Parent = game.StarterGui.ScreenGui
	LockObject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LockObject.BackgroundTransparency = 1.000
	LockObject.Position = UDim2.new(0.846670687, 0, 0.12040133, 0)
	LockObject.Size = UDim2.new(0.104459375, 0, 0.0334448144, 0)
	LockObject.Font = Enum.Font.SourceSans
	LockObject.Text = "Object Unlocked"
	LockObject.TextColor3 = Color3.fromRGB(255, 255, 255)
	LockObject.TextScaled = true
	LockObject.TextSize = 14.000
	LockObject.TextWrapped = true
	LockObject.TextXAlignment = Enum.TextXAlignment.Right
	
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)
	
	LockObject.MouseButton1Click:Connect(function()
		ObjectLocked = not ObjectLocked
		if ObjectLocked == true then
			LockObject.TextColor3 = Color3.fromRGB(170, 0, 0)
			LockObject.Text = 'Object Locked'
		else
			LockObject.TextColor3 = Color3.fromRGB(255, 255, 255)
			LockObject.Text = 'Object Unlocked'
		end
	end)
	
	return ScrollingFrame
	
end

local function CreateBoolTypeObject(Value, Attribute, attrValue, attrName)
	Value.Name = "Value"
	Value.Parent = Attribute
	Value.BackgroundColor3 = Color3.fromRGB(38, 39, 36)
	Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Value.Size = UDim2.new(0.157, 0, 0.714893639, 0)
	Value.Position = UDim2.new(.5-(Value.Size.X.Scale / 2), 0, 0.285106421, 0) -- x is an equation to set the button in the center of the screen
	Value.Font = Enum.Font.SourceSans
	if attrValue == true then
		Value.Text = 'X'
	else
		Value.Text = ' '
	end
	Value.TextColor3 = Color3.fromRGB(255, 255, 255)
	Value.TextSize = 14.000

	Value.MouseButton1Click:Connect(function()
		-- ran out of time but this needs to be updated to take in input from the user and flip the bool value, as well as flip the text
		-- i.e. bool is true, text is "X" ---> bool is false, text is " "
		if Value.Text == 'X' then
			LastSelection:SetAttribute(attrName, true)
		elseif Value.Text == ' ' then
			LastSelection:SetAttribute(attrName, false)
		end
	end)
	
end

local function CreateTextTypeObject(Value, Attribute, attrValue, attrType, attrName)
	Value.Name = "Value"
	Value.Parent = Attribute
	Value.BackgroundColor3 = Color3.fromRGB(38, 39, 36)
	Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Value.Position = UDim2.new(0, 0, 0.285106421, 0)
	Value.Size = UDim2.new(1, 0, 0.714893639, 0)
	Value.Font = Enum.Font.SourceSans
	Value.Text = attrValue
	Value.TextColor3 = Color3.fromRGB(255, 255, 255)
	Value.TextSize = 14.000

	Value.FocusLost:Connect(function()
		local success, err = pcall(function()
			local valueToReturn = nil
			if attrType == 'number' then
				local valueText = string.lower(Value.Text)
				valueToReturn = tonumber(valueText)
				if valueToReturn == nil then
					warn('Your change was not valid: "' .. Value.Text .. '" is not a valid number.') 
					return
				end
			elseif attrType == 'string' then
				valueToReturn = Value.Text
			end
			
			LastSelection:SetAttribute(attrName, valueToReturn)
		end)
		
		if not success then 
			warn('For some reason, your change was not valid:', err) 
		end
	end)
	
end

local function CreateAttribute(attrName, attrValue, attrType, Pos)
	
	
	local Attribute = Instance.new("Frame")
	local Name = Instance.new("TextLabel")
	local Value = Instance.new("TextBox")
	
	if attrType == 'boolean' then
		Value:Destroy()
		Value = Instance.new("TextButton")
		CreateBoolTypeObject(Value, Attribute, attrValue, attrName)
	elseif attrType == 'number' or attrType == 'string' then
		CreateTextTypeObject(Value, Attribute, attrValue, attrName)
	end
	
	Attribute.Name = "Attribute"
	Attribute.Parent = Ui
	Attribute.BackgroundColor3 = Color3.fromRGB(38, 39, 36)
	Attribute.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Attribute.Position = Pos
	Attribute.Size = UDim2.new(0, 211, 0, 47)

	Name.Name = "Name"
	Name.Parent = Attribute
	Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name.BackgroundTransparency = 1.000
	Name.Position = UDim2.new(0, 0, -1.62327538e-07, 0)
	Name.Size = UDim2.new(1, 0, 0.200000003, 0)
	Name.Font = Enum.Font.SourceSans
	Name.Text = "Name: " .. attrName .. " || Type: " .. tostring(attrType)
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextSize = 14.000
	Name.TextXAlignment = Enum.TextXAlignment.Left
	
	return Attribute
	
end

-- local selectedObject = Selection:Get()[1]

local function onAttributesClicked()
	-- create a new UI to view the attributes
	if not UiPresent then
		Ui = CreateUi("nil", "nil", "nil")
		local uiConn
		uiConn = Ui.Parent.Destroying:Connect(function()
			UiPresent = false
			Ui = nil
			uiConn:Disconnect()
		end)
		UiPresent = true
	end
	
end

AttributesEditor.Click:Connect(onAttributesClicked)

Selection.SelectionChanged:Connect(function()
	local SelectedObject
	if not ObjectLocked then
		SelectedObject = Selection:Get()[1]
	else 
		SelectedObject = LastSelection
	end
	
	-- if there is not a selected object just return
	if not SelectedObject then
		return 
	end
	
	LastSelection = SelectedObject
	
	-- clear old attributes if there is a new selection
	for _, Attribute in pairs(attributeObjects) do
		Attribute:Destroy()
	end
	
	local Attributes = SelectedObject:GetAttributes()
	if UiPresent then
		
		local index = 1
		for name, value in Attributes do
			-- create new attribute objects
			local pos = defaultPos  + UDim2.new(0, 0, 0, yModifier * index)
			table.insert(attributeObjects, CreateAttribute(name, value, typeof(value), pos))
			index += 1
		end
		
	end
end)
