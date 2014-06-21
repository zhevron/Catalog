require "GameLib"

Catalog = {}
Catalog.Version = "0.0.1"

local Defaults = {
  ["Locale"] = "en",
  ["Locked"] = false,
  ["Position"] = {
    ["X"] = 100,
    ["Y"] = 100
  }
}

Catalog.Locale = {}
Catalog.Options = {}
Catalog.Database = {}

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
  self.Settings:Init()
  Apollo.RegisterSlashCommand("catalog", "Open", self.Browser)
  Apollo.RegisterSlashCommand("loot", "Open", self.Browser)
end

function Catalog:OnSave(level)
  if level == GameLib.CodeEnumAddonSaveLevel.Character then
    return Catalog.Utility:TableCopyRecursive(self.Options)
  else
    return nil
  end
end

function Catalog:OnRestore(level, options)
  if level == GameLib.CodeEnumAddonSaveLevel.Character then
    for k, v in pairs(Defaults) do
      if not options[k] then
        options[k] = v
      end
    end
    self.Options = Catalog.Utility:TableCopyRecursive(options, self.Options)
  end
end

function Catalog:OnConfigure()
  self.Settings:Open()
end

function Catalog:GetLocale()
  if self.Locale[self.Options.Locale] then
    return self.Locale[self.Options.Locale]
  else
    return self.Locale["en"]
  end
end

local CatalogInst = Catalog:new()
CatalogInst:Init()
