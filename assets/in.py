#!/usr/bin/env python3

import sys
import json

from helpers.fetcher import Fetcher

# Redirect stdout to stderr for logging;  print to stdout only for Concourse
concourse_stream = sys.stdout
sys.stdout = sys.stderr

fetcher = Fetcher()

print(json.dumps(fetcher.get()), file=concourse_stream)