require "Window"

-- Initialize the addon module
LootIndex = {}

-- Define the database table (Loaded from the 'Database' subfolder)
LootIndex_DB = {}

-- Initialize a new instance of the addon
function LootIndex:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Initialize the addon
function LootIndex:Init()
  Apollo.RegisterAddon(self)
end

-- Called when the addon has loaded
function LootIndex:OnLoad()
  --
end

-- Create a new instance and initialize it
local LootIndexInst = LootIndex:new()
LootIndexInst:Init()
