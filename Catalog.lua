require "GameLib"

Catalog = {}

Catalog.Version = {
  ["Major"] = 0,
  ["Minor"] = 0,
  ["Build"] = 3
}

Catalog.Defaults = {
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

function Catalog:OnSave(type)
  if type ~= GameLib.CodeEnumAddonSaveLevel.Account then
    return nil
  end
  return Catalog.Utility:TableCopyRecursive(self.Options)
end

function Catalog:OnRestore(level, options)
  if level ~= GameLib.CodeEnumAddonSaveLevel.Account then
    return
  end
  for k, v in pairs(Catalog.Defaults) do
    if options[k] == nil then
      options[k] = v
    end
  end
  self.Options = Catalog.Utility:TableCopyRecursive(options, self.Options)
end

function Catalog:OnConfigure()
  self.Browser:Open()
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
