import sys
import json

try:
    if (sys.argv[1] == "add"):
        data = json.load(open("./disks_add.json"))
        data.append(sys.argv[2])
        json.dump(data, open("./disks_add.json", "w"))
    elif (sys.argv[1] == "remove"):
        data = json.load(open("./disks_remove.json"))
        data.append(sys.argv[2])
        json.dump(data, open("./disks_remove.json", "w"))
    else:
        print("Invalid usage")
except IndexError:
    print("Invalid usage")