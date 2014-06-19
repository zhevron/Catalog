Catalog = {}

Catalog_DB = {}

function Catalog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Catalog:Init()
  Apollo.RegisterAddon(self)
end

function Catalog:OnLoad()
  self.Browser:Init()
  Apollo.RegisterSlashCommand("catalog", "Open", self.Browser)
  Apollo.RegisterSlashCommand("loot", "Open", self.Browser)
end

local CatalogInst = Catalog:new()
CatalogInst:Init()
