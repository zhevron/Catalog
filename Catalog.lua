require "Window"

-- Initialize the addon module
Catalog = {}

-- Define the database table (Loaded from the 'Database' subfolder)
Catalog_DB = {}

-- Initialize a new instance of the addon
function Catalog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Initialize the addon
function Catalog:Init()
  Apollo.RegisterAddon(self)
  Apollo.RegisterSlashCommand("loot", "Open", self.Browser)
end

-- Called when the addon has loaded
function Catalog:OnLoad()
  --
end

-- Create a new instance and initialize it
local CatalogInst = Catalog:new()
CatalogInst:Init()
