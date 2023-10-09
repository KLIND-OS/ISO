import sys
import json
data = json.load(open("/home/kuba/scripts_run.json"))
data.append(sys.argv[1])
json.dump(data, open("/home/kuba/scripts_run.json", "w"))