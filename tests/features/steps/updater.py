import os
import sys
import json
import random
import unittest
from unittest.mock import patch
from pathlib import Path
from behave import *

from assets.helpers.updater import Updater, UpdaterError
from assets.helpers.git_server import BitbucketServerAPI


@Given("the put file {filename} contains {contents}")
def step_impl(context, filename, contents):
    filename = os.path.join(context.destination, filename)
    with open(filename, "w") as output_file:
        output_file.write(contents)


@When("updating the pull request")
def step_impl(context):
    try:
        with patch.object(sys.stdin, "read", return_value=json.dumps(context.resource_config.get_config())),\
                 patch.object(sys, "argv", ["/opt/resource/in", context.destination]),\
                 patch.object(BitbucketServerAPI, "update_commit_build_status", return_value=None):
            context.updater = Updater()
            context.updater_results = context.updater.put()
    except UpdaterError as e:
        context.updater_results = e


@Then("the put result should match the following")
def step_impl(context):
    assert context.updater_results == json.loads(context.text)


@Then("the put should have encountered an error")
def step_impl(context):
    assert isinstance(context.updater_results, UpdaterError)
