import json, os

class Exporter:
  def __init__(self, data_path):
    with open(os.path.join(data_path, "jabbithole-loot-table.json")) as file:
      self.json = json.load(file)

  def adventure(self, data):
    try:
      zone = self.get_zone_data("Adventures", data["name"]["en"])
      data["bosses"][0]["drops"] = []
      for k, v in zone.iteritems():
        data["bosses"][0]["drops"].append(int(k))
      return data
    except KeyError:
      print "  Not found in Jabbithole database!"
      return data

  def dungeon(self, data):
    try:
      zone = self.get_zone_data("Dungeons", data["name"]["en"])
      for k, v in enumerate(data["bosses"]):
        data["bosses"][k]["drops"] = []
        for k2, v2 in zone.iteritems():
          if v["name"]["en"] in v2:
            data["bosses"][k]["drops"].append(int(k2))
      return data
    except KeyError:
      print "  Not found in Jabbithole database!"
      return data

  def raid(self, data):
    try:
      zone = self.get_zone_data("Raids", data["name"]["en"])
      for k, v in enumerate(data["bosses"]):
        data["bosses"][k]["drops"] = []
        for k2, v2 in zone.iteritems():
          if v["name"]["en"] in v2:
            data["bosses"][k]["drops"].append(int(k2))
      return data
    except KeyError:
      print "  Not found in Jabbithole database!"
      return data

  def get_zone_data(self, type, name):
    return self.json[type][name]
