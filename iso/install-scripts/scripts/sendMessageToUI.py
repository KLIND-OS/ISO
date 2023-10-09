import sys
import json
import os
data = json.load(os.path.join(os.path.expanduser('~'),"/scripts_run.json"))
data.append(sys.argv[1])
json.dump(data, os.path.join(os.path.expanduser('~'),"/scripts_run.json"), "w"))