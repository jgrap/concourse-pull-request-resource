#!/usr/bin/env python3

import os
from pathlib import Path

def before_feature(context, feature):
    if feature.name == "Concourse Resource Put Functionality":
        os.environ["BUILD_ID"] = "1"
        os.environ["BUILD_NAME"] = "1"
        os.environ["BUILD_JOB_NAME"] = "Job_Name"
        os.environ["BUILD_PIPELINE_NAME"] = "Pipeline_Name"
        os.environ["BUILD_TEAM_NAME"] = "Team_Name"
        os.environ["ATC_EXTERNAL_URL"] = "https://concourse.local"


def after_scenario(context, scenario):
    for filename in ["pull_request_id", "pull_request_commit_id", "pull_request_update_date"]:
        file_path = Path(os.path.join("/tmp", filename))
        if file_path.exists():
            file_path.unlink()


def after_feature(context, feature):
    if feature.name == "Concourse Resource Put Functionality":
        del os.environ["BUILD_ID"]
        del os.environ["BUILD_NAME"]
        del os.environ["BUILD_JOB_NAME"]
        del os.environ["BUILD_PIPELINE_NAME"]
        del os.environ["BUILD_TEAM_NAME"]
        del os.environ["ATC_EXTERNAL_URL"]