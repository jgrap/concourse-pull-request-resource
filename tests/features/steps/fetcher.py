import os
import sys
import json
import random
import unittest
from unittest.mock import patch
from pathlib import Path
from behave import *

from assets.helpers.fetcher import Fetcher, FetcherError
from assets.helpers.git_server import BitbucketServerAPI


@Given("a mock response from Bitbucket for pull request of")
def step_impl(context):
    context.pull_request = json.loads(context.text)


@Given("a mock response from Bitbucket for commit of")
def step_impl(context):
    if "commits" not in context:
        context.commits = [ json.loads(context.text) ]
    else:
        context.commits.append(json.loads(context.text))


@When("fetching the pull request")
def step_impl(context):
    try:
        with patch.object(sys.stdin, "read", return_value=json.dumps(context.resource_config.get_config())),\
                 patch.object(sys, "argv", ["/opt/resource/in", context.destination]),\
                 patch.object(BitbucketServerAPI, "get_pull_request", return_value=context.pull_request),\
                 patch.object(BitbucketServerAPI, "get_commit", side_effect=context.commits),\
                 patch.object(Fetcher, "get_archive", return_value=""):
            context.fetcher = Fetcher()
            context.fetcher_results = context.fetcher.get()
    except FetcherError as e:
        context.fetcher_results = e


@Then("the get result should match the following")
def step_impl(context):
    assert context.fetcher_results == json.loads(context.text)


@Then("the get file {filename} should contain {contents}")
def step_impl(context, filename, contents):
    filename = os.path.join(context.destination, filename)
    with open(filename) as input_file:
        file_contents = input_file.read().strip()
    assert file_contents == contents


@Then("the get should have encountered an error")
def step_impl(context):
    assert isinstance(context.fetcher_results, FetcherError)
