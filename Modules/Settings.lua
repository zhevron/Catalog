local Catalog = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("Catalog")
local Settings = Catalog:NewModule("Settings")

function Settings:OnInitialize()
  self.Xml = XmlDoc.CreateFromFile("Forms/Settings.xml")
  if self.Xml == nil then
    Apollo.AddAddonErrorText(Catalog, "Could not load the Catalog settings window")
    return
  end
  self.Xml:RegisterCallback("OnDocumentReady", self)
end

function Settings:OnDocumentReady()
  self.Window = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
  self.Window:FindChild("AutoButton"):SetData("auto")
  self.Window:FindChild("EnglishButton"):SetData("en")
  self.Window:FindChild("GermanButton"):SetData("de")
  self.Window:FindChild("FrenchButton"):SetData("fr")
  local version = Catalog.Version.Major.."."..Catalog.Version.Minor.."."..Catalog.Version.Build
  self.Window:FindChild("VersionText"):SetText(version)
end

function Settings:Open()
  local Wishlist = Catalog:GetModule("Wishlist")
  if self.Window and self.Window:IsValid() then
    Wishlist:Close()
    self:Position()
    self:Localize()
    self:ApplyCurrent()
    self.Window:Show(true)
  end
end

function Settings:Close()
  local Browser = Catalog:GetModule("Browser")
  if self.Window and self.Window:IsValid() then
    Browser.Window:FindChild("SettingsButton"):SetCheck(false)
    self.Window:Show(false)
  end
end

function Settings:Localize()
  local locale = Catalog:GetLocale()
  self.Window:FindChild("LockedButton"):SetText(locale["lock"])
end

function Settings:Position()
  local Browser = Catalog:GetModule("Browser")
  local _, top, right = Browser.Window:GetAnchorOffsets()
  local offset = (right - 15) * (1 - Browser.Window:GetScale())
  local form = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
  local _, _, width, height = form:GetAnchorOffsets()
  form:Destroy()
  self.Window:SetAnchorOffsets(right - 15 - offset, top + 5, right - 15 -offset + width, top + 5 + height)
  self.Window:SetScale(Browser.Window:GetScale())
end

function Settings:ApplyCurrent()
  if Catalog.Options.Account.AutoLocale then
    self.Window:FindChild("AutoButton"):SetCheck(true)
    self.Window:FindChild("EnglishButton"):SetCheck(false)
    self.Window:FindChild("GermanButton"):SetCheck(false)
    self.Window:FindChild("FrenchButton"):SetCheck(false)
  else
    self.Window:FindChild("AutoButton"):SetCheck(false)
    self.Window:FindChild("EnglishButton"):SetCheck(Catalog.Options.Account.Locale == "en")
    self.Window:FindChild("GermanButton"):SetCheck(Catalog.Options.Account.Locale == "de")
    self.Window:FindChild("FrenchButton"):SetCheck(Catalog.Options.Account.Locale == "fr")
  end
  self.Window:FindChild("ScaleValueText"):SetText(tostring(Catalog.Options.Account.Scale))
  self.Window:FindChild("ScaleSlider"):SetValue(Catalog.Options.Account.Scale)
  self.Window:FindChild("LockedButton"):SetCheck(Catalog.Options.Account.Locked)
end

function Settings:OnLocaleListOpen(handler, control)
  self.Window:FindChild("LocaleList"):Show(true)
end

function Settings:OnLocaleListClose(handler, control)
  self.Window:FindChild("LocaleList"):Show(false)
end

function Settings:OnChangeLocale(handler, control)
  local Browser = Catalog:GetModule("Browser")
  local Wishlist = Catalog:GetModule("Wishlist")
  self.Window:FindChild("LocaleButton"):SetText(control:GetText())
  self.Window:FindChild("LocaleButton"):SetCheck(false)
  self.Window:FindChild("LocaleList"):Show(false)
  if control:GetData() == "auto" then
    Catalog.Options.Account.AutoLocale = true
  else
    Catalog.Options.Account.AutoLocale = false
    Catalog.Options.Account.Locale = control:GetData()
  end
  self:Localize()
  Browser:Localize()
  Wishlist:Localize()
end

function Settings:OnScaleChanged(handler, control, scale)
  local Browser = Catalog:GetModule("Browser")
  scale = math.floor(scale * math.pow(10, 1) + 0.5) / math.pow(10, 1)
  self.Window:FindChild("ScaleValueText"):SetText(tostring(scale))
  self.Window:SetScale(scale)
  Browser.Window:SetScale(scale)
  Catalog.Options.Account.Scale = scale
  self:Position()
end

function Settings:OnToggleLocked(handler, control)
  local Browser = Catalog:GetModule("Browser")
  Catalog.Options.Account.Locked = control:IsChecked()
  if not Catalog.Options.Account.Locked then
    Browser.Window:AddStyle("Moveable")
  else
    Browser.Window:RemoveStyle("Moveable")
  end
end
