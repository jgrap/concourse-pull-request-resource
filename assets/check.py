#!/usr/bin/env python3

import sys
import json

from helpers.checker import Checker

# Redirect stdout to stderr for logging;  print to stdout only for Concourse
concourse_stream = sys.stdout
sys.stdout = sys.stderr

checker = Checker()

print(json.dumps(checker.check()), file=concourse_stream)
