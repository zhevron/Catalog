require "GameLib"

Catalog = {}

Catalog.Version = {
  ["Major"] = 1,
  ["Minor"] = 0,
  ["Build"] = 3
}

Catalog.Defaults = {
  ["Account"] = {
    ["Locale"] = "en",
    ["AutoLocale"] = true,
    ["Locked"] = false,
    ["Position"] = {
      ["X"] = 100,
      ["Y"] = 100
    },
    ["Scale"] = 1.0
  },
  ["Character"] = {
    ["ItemTypes"] = {},
    ["ShowHidden"] = true,
    ["Wishlist"] = {}
  }
}

Catalog.Locale = {}
Catalog.Database = {}
Catalog.Options = Catalog.Defaults

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
  self.Wishlist:Init()
  Apollo.RegisterSlashCommand("catalog", "Open", self.Browser)
  Apollo.RegisterSlashCommand("loot", "Open", self.Browser)
  Apollo.RegisterSlashCommand("catalogreset", "Reset", self)
  Apollo.RegisterEventHandler("Catalog_ToggleBrowser", "Toggle", self.Browser)
  Apollo.RegisterEventHandler("LootRollUpdate", "OnGroupLoot", self.Wishlist)
  Apollo.RegisterEventHandler("LootedItem", "OnItemLooted", self.Wishlist)
  Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
end

function Catalog:OnInterfaceMenuListHasLoaded()
  Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Catalog", {
    "Catalog_ToggleBrowser",
    "",
    "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_Lore"
  })
end

function Catalog:OnSave(type)
  if type == GameLib.CodeEnumAddonSaveLevel.Character then
    return Catalog.Utility:TableCopyRecursive(self.Options.Character)
  elseif type == GameLib.CodeEnumAddonSaveLevel.Account then
    return Catalog.Utility:TableCopyRecursive(self.Options.Account)
  end
  return nil
end

function Catalog:OnRestore(type, table)
  if type == GameLib.CodeEnumAddonSaveLevel.Character then
    for k, v in pairs(Catalog.Defaults.Character) do
      if table[k] == nil then
        table[k] = v
      end
    end
    self.Options.Character = Catalog.Utility:TableCopyRecursive(table, self.Options.Character)
  elseif type == GameLib.CodeEnumAddonSaveLevel.Account then
    for k, v in pairs(Catalog.Defaults.Account) do
      if table[k] == nil then
        table[k] = v
      end
    end
    self.Options.Account = Catalog.Utility:TableCopyRecursive(table, self.Options.Account)
  end
end

function Catalog:OnConfigure()
  self.Browser:Open()
end

function Catalog:GetLocale()
  if self.Options.Account.AutoLocale then
    local locale = Apollo.GetConsoleVariable("locale.languageId")
    if locale == 1 then
      return self.Locale["en"]
    elseif locale == 2 then
      return self.Locale["de"]
    elseif locale == 3 then
      return self.Locale["fr"]
    else
      return self.Locale["en"]
    end
  end
  if self.Locale[self.Options.Account.Locale] then
    return self.Locale[self.Options.Account.Locale]
  else
    return self.Locale["en"]
  end
end

function Catalog:Reset()
  self.Options.Account.Position = self.Defaults.Account.Position
  self.Options.Account.Scale = self.Defaults.Account.Scale
  self.Browser:Close()
  self.Browser:Open()
end

local CatalogInst = Catalog:new()
CatalogInst:Init()
