require "GameLib"

Catalog = {}
Catalog.Version = "0.0.1"

local Defaults = {
  ["Locale"] = "en",
  ["Position"] = {
    ["X"] = 100,
    ["Y"] = 100
  }
}

Catalog.Locale = {}
Catalog.Options = {}
Catalog_DB = {}

function Catalog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Catalog:Init()
  Apollo.RegisterAddon(self, true, "Catalog")
end

function Catalog:OnLoad()
  self.Browser:Init()
  Apollo.RegisterSlashCommand("catalog", "Open", self.Browser)
  Apollo.RegisterSlashCommand("loot", "Open", self.Browser)
end

function Catalog:OnSave(level)
  if level == GameLib.CodeEnumAddonSaveLevel.Character then
    return self.Options
  else
    return nil
  end
end

function Catalog:OnRestore(level, options)
  if level == GameLib.CodeEnumAddonSaveLevel.Character then
    self.Options = options
    for k, v in pairs(Defaults) do
      if not self.Options[k] then
        self.Options[k] = v
      end
    end
  end
end

function Catalog:OnConfigure()
  --
end

local CatalogInst = Catalog:new()
CatalogInst:Init()
