import copy, glob, json, os, sys

from jabbithole import *
from wildheap import *

script_path = os.path.dirname(os.path.realpath(sys.argv[0]))
root_path = os.path.abspath(os.path.join(script_path, os.pardir))
data_path = os.path.join(root_path, "Data")
database_path = os.path.join(root_path, "Database")

exporters = {}
exporters["jabbithole"] = JabbitholeExporter(data_path)
exporters["wildheap"] = WildheapExporter()

def parse_data(name, data, folder, type):
  print "Parsing " + type + ": " + data["name"]["en"]
  for k, v in enumerate(data["bosses"]):
    data["bosses"][k]["drops"] = []
  parsed = copy.deepcopy(data)
  for k, v in exporters.iteritems():
    res = {}
    if type == "adventure":
      res = v.adventure(data)
    elif type == "dungeon":
      res = v.dungeon(data)
    elif type == "raid":
      res = v.raid(data)
    parsed = merge_data(parsed, res)
  num = 0
  for k, v in enumerate(parsed["bosses"]):
    num += len(v["drops"])
  print "  Number of drops: " + str(num)
  write_database_file(os.path.join(database_path, folder, name + ".lua"), parsed, type)

# Check if a given boss table already contains an item
def boss_has_item(data, boss, item):
  for k, v in enumerate(data["bosses"]):
    if v["name"]["en"] == boss["name"]["en"]:
      for k2, v2 in enumerate(v["drops"]):
        if int(v2) == int(item):
          return True
  return False

# Add an item to a given boss table if it's not already on it.
def boss_add_item(data, boss, item):
  if not boss_has_item(data, boss, item):
    for k, v in enumerate(data["bosses"]):
      if v["name"]["en"] == boss["name"]["en"]:
        data["bosses"][k]["drops"].append(item)
  return data

# Merge two data sets
def merge_data(dst, src):
  for k, v in enumerate(src["bosses"]):
    for k2, v2 in enumerate(v["drops"]):
      boss_add_item(dst, v, v2)
  return dst

# Write a database file
def write_database_file(path, data, type):
  name = os.path.splitext(os.path.basename(path))[0]
  with open(path, "w") as file:
    file.write("-- [{}] {}\n".format(type.capitalize(), data["name"]["en"]))
    file.write("Catalog.Database[\"{}\"] = {}\n".format(name, "{"))
    file.write("  [\"name\"] = {\n")
    for k, v in data["name"].iteritems():
      file.write("    [\"{}\"] = \"{}\",\n".format(k, v.encode("utf8")))
    file.write("  },\n")
    file.write("  [\"type\"] = \"{}\",\n".format(type))
    file.write("  [\"bosses\"] = {\n")
    for boss in data["bosses"]:
      file.write("    {\n")
      file.write("      [\"name\"] = {\n")
      for k, v in boss["name"].iteritems():
        file.write("        [\"{}\"] = \"{}\",\n".format(k, v.encode("utf8")))
      file.write("      },\n")
      if boss["veteran"]:
        file.write("      [\"veteran\"] = true,\n")
      else:
        file.write("      [\"veteran\"] = false,\n")
      file.write("      [\"drops\"] = {\n")
      for item in boss["drops"]:
        file.write("        {},\n".format(item))
      file.write("      },\n")
      file.write("    },\n")
    file.write("  },\n")
    file.write("}\n")

print "Catalog Data Extractor\n"

for filename in glob.glob(os.path.join(data_path, "Adventures", "*.json")):
  with open(os.path.realpath(filename)) as file:
    data = json.load(file)
    parse_data(os.path.splitext(os.path.basename(filename))[0], data, "Adventures", "adventure")

for filename in glob.glob(os.path.join(data_path, "Dungeons", "*.json")):
  with open(os.path.realpath(filename)) as file:
    data = json.load(file)
    parse_data(os.path.splitext(os.path.basename(filename))[0], data, "Dungeons", "dungeon")

for filename in glob.glob(os.path.join(data_path, "Raids", "*.json")):
  with open(os.path.realpath(filename)) as file:
    data = json.load(file)
    parse_data(os.path.splitext(os.path.basename(filename))[0], data, "Raids", "raid")

print "\nComplete!"
