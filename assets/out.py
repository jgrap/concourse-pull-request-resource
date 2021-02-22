#!/usr/bin/env python3

import sys
import json

from helpers.updater import Updater

# Redirect stdout to stderr for logging;  print to stdout only for Concourse
concourse_stream = sys.stdout
sys.stdout = sys.stderr

updater = Updater()

print(json.dumps(updater.put()), file=concourse_stream)