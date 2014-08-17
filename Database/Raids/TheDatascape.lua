local Catalog = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("Catalog")
local Database = Catalog:GetModule("Database")

-- [Raid] The Datascape
Database.tEntries["TheDatascape"] = {
  ["name"] = {
    ["frFR"] = "L'Infosphère",
    ["deDE"] = "Datenzone",
    ["enUS"] = "The Datascape",
  },
  ["type"] = "raid",
  ["bosses"] = {
  },
}
