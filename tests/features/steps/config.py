#!/usr/bin/env python3

import json
from behave import *
from assets.helpers.config import Config


@When("requesting config object with key {key}")
def step_impl(context, key):
    context.config_object = context.resource_config.get(key)


@When("requesting config item from source {source} with key {key}")
def step_impl(context, source, key):
    context.config_item = context.resource_config.get(key, source)


@Then("the source config is valid")
def step_impl(context):
    assert context.resource_config.is_valid_source_config() is True


@Then("the source config is invalid")
def step_impl(context):
    assert context.resource_config.is_valid_source_config() is False


@Then("the retrieved config object should be")
def step_impl(context):
    assert context.config_object == json.loads(context.text)


@Then("the retrieved config item should be {item}")
def step_impl(context, item):
    assert context.config_item == item


@Then("the retrieved config object shouldn't exist")
def step_impl(context):
    assert context.config_object == None


@Then("the retrieved config item shouldn't exist")
def step_impl(context):
    assert context.config_item == None