import sys
import json
import random
import unittest
from unittest.mock import patch
from pathlib import Path
from behave import *

from assets.helpers.checker import Checker, CheckerError
from assets.helpers.git_server import BitbucketServerAPI


@Given("a mock response from Bitbucket for pull requests of")
def step_impl(context):
    context.pull_requests = json.loads(context.text)


@Given("a mock response from Bitbucket for pull request commits of")
def step_impl(context):
    context.pull_request_commits = json.loads(context.text)


@Given("a mock response from Bitbucket for pull request changes of")
def step_impl(context):
    context.pull_request_changes = json.loads(context.text)


@When("checking for new versions")
def step_impl(context):
    resource_config_as_string = json.dumps(context.resource_config.get_config())
    try:
        with patch.object(sys.stdin, "read", return_value=resource_config_as_string):
            context.checker = Checker()
        with patch.object(BitbucketServerAPI, "get_pull_requests", return_value=context.pull_requests),\
             patch.object(BitbucketServerAPI, "get_pull_request_commits", return_value=context.pull_request_commits),\
             patch.object(BitbucketServerAPI, "get_pull_request_changes", return_value=context.pull_request_changes):
            context.checker_results = context.checker.check()
    except CheckerError as e:
        context.checker_results = e


@Then("the check result should match the following")
def step_impl(context):
    assert context.checker_results == json.loads(context.text)


@Then("the check should have encountered an error")
def step_impl(context):
    assert isinstance(context.checker_results, CheckerError)
