import glob, json, os, sys, urllib2

http_headers = {
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:30.0) Gecko/20100101 Firefox/30.0"
}

script_path = os.path.dirname(os.path.realpath(sys.argv[0]))

class Item:
  def __init__(self):
    self.id = 0
    self.name = ""

def parse_adventure(name, data):
  print "Parsing adventure: " + name
  with open(os.getcwd() + "/" + name + ".txt", "w") as file:
    #

def parse_dungeon(name, data):
  print "Parsing dungeon: " + name
  with open(os.getcwd() + "/" + name + ".txt", "w") as file:
    for boss in data["bosses"]:
      print "  Parsing boss: " + boss
      file.write("#### " + boss + "\n\n")
      file.write("## Normal\n")
      for item in parse_npc(boss, "maxlevel=" + str(data["level"])):
        file.write(str(item.id) + ", -- " + item.name + "\n")
      file.write("\n## Veteran\n")
      for item in parse_npc(boss, "minlevel=" + str(data["level"] + 1)):
        file.write(str(item.id) + ", -- " + item.name + "\n")
      file.write("\n")

def parse_raid(name, data):
  print "Parsing raid: " + name
  with open(os.getcwd() + "/" + name + ".txt", "w") as file:
    for boss in data["bosses"]:
      print "  Parsing boss: " + boss
      file.write("#### " + boss + "\n")
      for item in parse_npc(boss, "maxlevel=" + str(data["level"])):
        file.write(str(item.id) + ", -- " + item.name + "\n")
      file.write("\n")

def parse_npc(name, filter):
  items = []
  url = "https://api.wildheap.com/items?droppedby=" + name.replace(" ", "%20") + "&" + filter
  req = urllib2.Request(url, headers = http_headers)
  data = json.load(urllib2.urlopen(req))
  if data["total"] > 0:
    for iteminfo in data["items"]:
      item = Item()
      item.id = iteminfo["id"]
      item.name = iteminfo["name"]
      items.append(item)
  return items

print "Catalog Data Extractor\n"

for filename in glob.glob(script_path + "/Dungeons/*.json"):
  with open(os.path.realpath(filename)) as file:
    data = json.load(file)
    parse_dungeon(os.path.splitext(os.path.basename(filename))[0], data)

for filename in glob.glob(script_path + "/Raids/*.json"):
  with open(os.path.realpath(filename)) as file:
    data = json.load(file)
    parse_raid(os.path.splitext(os.path.basename(filename))[0], data)

print "\nComplete!"
