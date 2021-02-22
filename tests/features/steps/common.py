#!/usr/bin/env python3

import json
from behave import *
from assets.helpers.config import Config


@Given("the resource config of")
def step_impl(context):
    context.resource_config = Config(config=json.loads(context.text))


@Given("a mock destination from Concourse of {destination}")
def step_impl(context, destination):
    context.destination = destination