require "Window"

Catalog.Settings = {}

function Catalog.Settings:Init()
  self.Xml = XmlDoc.CreateFromFile("Forms/Settings.xml")
  self.Xml:RegisterCallback("OnDocumentReady", self)
end

function Catalog.Settings:OnDocumentReady()
  if self.Xml == nil then
    Apollo.AddAddonErrorText(Catalog, "Could not load the Catalog settings window")
    return
  end
  self.Window = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
  self:Close()
  self.Window:FindChild("AutoButton"):SetData("auto")
  self.Window:FindChild("EnglishButton"):SetData("en")
  self.Window:FindChild("GermanButton"):SetData("de")
  self.Window:FindChild("FrenchButton"):SetData("fr")
  local version = Catalog.Version.Major.."."..Catalog.Version.Minor.."."..Catalog.Version.Build
  self.Window:FindChild("VersionText"):SetText(version)
end

function Catalog.Settings:Open()
  if self.Window and self.Window:IsValid() then
    Catalog.Wishlist:Close()
    self:Position()
    self:Localize()
    self:ApplyCurrent()
    self.Window:Show(true)
  end
end

function Catalog.Settings:Close()
  if self.Window and self.Window:IsValid() then
    Catalog.Browser.Window:FindChild("SettingsButton"):SetCheck(false)
    self.Window:Show(false)
  end
end

function Catalog.Settings:Localize()
  local locale = Catalog:GetLocale()
  self.Window:FindChild("LockedButton"):SetText(locale["lock"])
end

function Catalog.Settings:Position()
  local _, top, right = Catalog.Browser.Window:GetAnchorOffsets()
  local offset = (right - 15) * (1 - Catalog.Browser.Window:GetScale())
  local form = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
  local _, _, width, height = form:GetAnchorOffsets()
  form:Destroy()
  self.Window:SetAnchorOffsets(right - 15 - offset, top + 5, right - 15 -offset + width, top + 5 + height)
  self.Window:SetScale(Catalog.Browser.Window:GetScale())
end

function Catalog.Settings:ApplyCurrent()
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

function Catalog.Settings:OnLocaleListOpen(handler, control)
  self.Window:FindChild("LocaleList"):Show(true)
end

function Catalog.Settings:OnLocaleListClose(handler, control)
  self.Window:FindChild("LocaleList"):Show(false)
end

function Catalog.Settings:OnChangeLocale(handler, control)
  self.Window:FindChild("LocaleButton"):SetText(control:GetText())
  self.Window:FindChild("LocaleButton"):SetCheck(false)
  self.Window:FindChild("LocaleList"):Show(false)
  if control:GetData() == "auto" then
    Catalog.Options.Account.AutoLocale = true
  else
    Catalog.Options.Account.AutoLocale = false
    Catalog.Options.Account.Locale = control:GetData()
  end
  Catalog.Browser:Localize()
  Catalog.Settings:Localize()
  Catalog.Wishlist:Localize()
end

function Catalog.Settings:OnScaleChanged(handler, control, scale)
  scale = math.floor(scale * math.pow(10, 1) + 0.5) / math.pow(10, 1)
  self.Window:FindChild("ScaleValueText"):SetText(tostring(scale))
  Catalog.Browser.Window:SetScale(scale)
  self.Window:SetScale(scale)
  Catalog.Options.Account.Scale = scale
  self:Position()
end

function Catalog.Settings:OnToggleLocked(handler, control)
  Catalog.Options.Account.Locked = control:IsChecked()
  if not Catalog.Options.Account.Locked then
    Catalog.Browser.Window:AddStyle("Moveable")
  else
    Catalog.Browser.Window:RemoveStyle("Moveable")
  end
end
