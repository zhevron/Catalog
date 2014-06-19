require "Window"

Catalog.Browser = {}

function Catalog.Browser:Init()
  self.Xml = XmlDoc.CreateFromFile("Forms/Browser.xml")
  self.Xml:RegisterCallback("OnDocumentReady", self)
end

function Catalog.Browser:OnDocumentReady()
  if self.Xml == nil then
    Apollo.AddAddonErrorText(Catalog, "Could not load the Catalog browser")
    return
  end
  self.Window = Apollo.LoadForm(self.Xml, "CatalogBrowser", nil, self)
  self:Close()
  self:BuildLocationList()
end

function Catalog.Browser:Open()
  if self.Window and self.Window:IsValid() then
    self.Window:Show(true)
  end
end

function Catalog.Browser:Close()
  if self.Window and self.Window:IsValid() then
    self.Window:Show(false)
  end
end

function Catalog.Browser:BuildLocationTypeList()
  --
end

function Catalog.Browser:BuildLocationList(type)
  --
end

function Catalog.Browser:BuildBossList(location)
  --
end

function Catalog.Browser:BuildLootList(boss)
  --
end
