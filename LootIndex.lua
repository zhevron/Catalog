-----------------------------------------------------------------------------------------------
-- Client Lua Script for LootIndex
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- LootIndex Module Definition
-----------------------------------------------------------------------------------------------
local LootIndex = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function LootIndex:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function LootIndex:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- LootIndex OnLoad
-----------------------------------------------------------------------------------------------
function LootIndex:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("LootIndex.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- LootIndex OnDocLoaded
-----------------------------------------------------------------------------------------------
function LootIndex:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "LootIndexForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- LootIndex Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here


-----------------------------------------------------------------------------------------------
-- LootIndexForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function LootIndex:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function LootIndex:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- LootIndex Instance
-----------------------------------------------------------------------------------------------
local LootIndexInst = LootIndex:new()
LootIndexInst:Init()
