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
  self:Localize()
  self.Window:FindChild("LocaleEnglishButton"):SetData("en")
  self.Window:FindChild("LocaleGermanButton"):SetData("de")
  self.Window:FindChild("LocaleFrenchButton"):SetData("fr")
end

function Catalog.Settings:Open()
  if self.Window and self.Window:IsValid() then
    self:Position()
    self:ApplyCurrent()
    self.Window:Show(true)
  end
end

function Catalog.Settings:Close()
  if self.Window and self.Window:IsValid() then
    self.Window:Show(false)
  end
end

function Catalog.Settings:Localize()
  local locale = Catalog:GetLocale()
  self.Window:FindChild("LocaleText"):SetText(locale["language"])
  self.Window:FindChild("LocaleEnglishText"):SetText(locale["english"])
  self.Window:FindChild("LocaleGermanText"):SetText(locale["german"])
  self.Window:FindChild("LocaleFrenchText"):SetText(locale["french"])
  self.Window:FindChild("LockedText"):SetText(locale["lock"])
end

function Catalog.Settings:Position()
  local _, top, right = Catalog.Browser.Window:GetAnchorOffsets()
  local form = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
  local _, _, width, height = form:GetAnchorOffsets()
  form:Destroy()
  self.Window:SetAnchorOffsets(right, top, right + width, top + height)
end

function Catalog.Settings:ApplyCurrent()
  self.Window:FindChild("LocaleEnglishButton"):SetCheck(Catalog.Options.Locale == "en")
  self.Window:FindChild("LocaleGermanButton"):SetCheck(Catalog.Options.Locale == "de")
  self.Window:FindChild("LocaleFrenchButton"):SetCheck(Catalog.Options.Locale == "fr")
  self.Window:FindChild("LockedButton"):SetCheck(Catalog.Options.Locked)
end

function Catalog.Settings:OnChangeLocale(handler, control)
  Catalog.Options.Locale = control:GetData()
  Catalog.Settings:Localize()
  Catalog.Browser:Localize()
  Catalog.Browser:BuildLocationList()
end

function Catalog.Settings:OnToggleLocked(handler, control)
  Catalog.Options.Locked = control:IsChecked()
  if not Catalog.Options.Locked then
    Catalog.Browser.Window:AddStyle("Moveable")
  else
    Catalog.Browser.Window:RemoveStyle("Moveable")
  end
end
