require "Item"
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
  self:Localize()
  self:BuildLocationTypeList()
end

function Catalog.Browser:Open()
  if self.Window and self.Window:IsValid() then
    local left = Catalog.Options.Position.X
    local top = Catalog.Options.Position.Y
    local form = Apollo.LoadForm(self.Xml, "CatalogBrowser", nil, self)
    local _, _, right, bottom = form:GetAnchorOffsets()
    form:Destroy()
    self.Window:SetAnchorOffsets(left, top, left + right, top + bottom)
    if Catalog.Options.Locked then
      self.Window:AddStyle("Moveable")
    else
      self.Window:RemoveStyle("Moveable")
    end
    self.Window:Show(true)
  end
end

function Catalog.Browser:Close()
  if self.Window and self.Window:IsValid() then
    local left, top = self.Window:GetAnchorOffsets()
    Catalog.Options.Position.X = left
    Catalog.Options.Position.Y = top
    self.Window:Show(false)
  end
end

function Catalog.Browser:Localize()
  local locale = Catalog:GetLocale()
  self.Window:FindChild("VeteranText"):SetText(locale["veteran"])
end

function Catalog.Browser:BuildLocationTypeList()
  local locale = Catalog:GetLocale()
  local types = { "adventure", "dungeon", "raid" }
  local list = self.Window:FindChild("LocationTypeList")
  list:DestroyChildren()
  for _, type in ipairs(types) do
    local name = Catalog.Utility:Capitalize(locale[type][2])
    local form = Apollo.LoadForm(self.Xml, "LocationType", list, self)
    form:SetData(type)
    form:FindChild("LocationTypeText"):SetText(name)
    --self:BuildLocationList(type, form)
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildLocationList(type, parent)
  local list = parent:FindChild("LocationList")
  list:DestroyChildren()
  local locations = {}
  for _, location in pairs(Catalog_DB) do
    if location.type == type then
      table.insert(locations, location)
    end
  end
  for name, location in Catalog.Utility:TableSortPairs(locations, "name") do
    local form = Apollo.LoadForm(self.Xml, "Location", list, self)
    form:SetData(location)
    form:FindChild("LocationText"):SetText(name)
    self:BuildBossList(location, form)
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildBossList(location, parent)
  local list = parent:FindChild("BossList")
  list:DestroyChildren()
  for _, boss in ipairs(location.bosses) do
    local form = Apollo.LoadForm(self.Xml, "Boss", list, self)
    form:SetData(boss)
    form:FindChild("BossText"):SetText(boss.name[Catalog.Options.Locale])
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildLootList(boss)
  local list = self.Window:FindChild("ItemList")
  list:DestroyChildren()
  local mode = "normal"
  if self.Window:FindChild("VeteranButton"):IsChecked() then
    mode = "veteran"
  end
  for _, id in ipairs(boss[mode]) do
    local item = Item.GetDataFromId(id)
    if item ~= nil then
      local form = Apollo.LoadForm(self.Xml, "Item", list, self)
      form:SetData(item)
      form:FindChild("ItemText"):SetText(item:GetName())
    end
  end
  list:ArrangeChildrenVert()
end
