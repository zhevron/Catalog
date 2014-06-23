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
end

function Catalog.Settings:Open()
  if self.Window and self.Window:IsValid() then
    local left, top = Catalog.Browser.Window:GetAnchorOffsets()
    local form = Apollo.LoadForm(self.Xml, "CatalogSettings", nil, self)
    local _, _, right, bottom = form:GetAnchorOffsets()
    form:Destroy()
    self.Window:SetAnchorOffsets(left + 5, top, left + 5 + right, top + bottom)
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
end

function Catalog.Settings:OnChangeLocale(handler, control)
  Catalog.Options.Locale = control:GetData()
end

function Catalog.Settings:OnToggleLocked(handler, control)
  Catalog.Options.Locked = control:IsChecked()
end
