local Catalog = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("Catalog", true)

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

function Catalog:OnInitialize()
  local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
  self.Log = GeminiLogging:GetLogger({
    level = GeminiLogging.INFO,
    pattern = "[%d %l %c:%n] %m",
    appender = "GeminiConsole"
  })
  Apollo.RegisterSlashCommand("catalogreset", "Reset", self)
end

function Catalog:OnEnable()
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
  local Utility = self:GetModule("Utility")
  if type == GameLib.CodeEnumAddonSaveLevel.Character then
    return Utility:TableCopyRecursive(self.Options.Character)
  elseif type == GameLib.CodeEnumAddonSaveLevel.Account then
    return Utility:TableCopyRecursive(self.Options.Account)
  end
  return nil
end

function Catalog:OnRestore(type, table)
  local Utility = self:GetModule("Utility")
  if type == GameLib.CodeEnumAddonSaveLevel.Character then
    for k, v in pairs(Catalog.Defaults.Character) do
      if table[k] == nil then
        table[k] = v
      end
    end
    self.Options.Character = Utility:TableCopyRecursive(table, self.Options.Character)
  elseif type == GameLib.CodeEnumAddonSaveLevel.Account then
    for k, v in pairs(Catalog.Defaults.Account) do
      if table[k] == nil then
        table[k] = v
      end
    end
    self.Options.Account = Utility:TableCopyRecursive(table, self.Options.Account)
  end
end

function Catalog:OnConfigure()
  local Browser = self:GetModule("Browser")
  Browser:Toggle()
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
  local Browser = self:GetModule("Browser")
  self.Options.Account.Position = self.Defaults.Account.Position
  self.Options.Account.Scale = self.Defaults.Account.Scale
  Browser:Close()
  Browser:Open()
end
