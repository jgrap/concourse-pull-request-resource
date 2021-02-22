#!/usr/bin/env python3

import os
import sys
import json
import tarfile
from pathlib import Path
from datetime import datetime, timezone

from .config import Config
from .git_server import BitbucketServerAPI


class UpdaterError(Exception):
    """
    Exception class raised for Fetcher errors

    Attributes:
        message (string)    Fetcher error message
    """

    def __init__(self, message):
        self.message = message


class Updater:
    """
    Class for handling get functionality for Concourse resource

    Attributes:
        __config       (dict)  Concourse resource configuration
        __destination  (Path)  Output directory to hold fetched Git repository
    """

    def __init__(self):

        self.__config = Config(config=json.loads(sys.stdin.read()))
        self.__destination = Path(sys.argv[1])
        self.__build_id = os.environ["BUILD_ID"]
        self.__build_name = os.environ["BUILD_NAME"]
        self.__build_job_name = os.environ["BUILD_JOB_NAME"]
        self.__build_pipeline_name = os.environ["BUILD_PIPELINE_NAME"]
        self.__build_team_name = os.environ["BUILD_TEAM_NAME"]
        self.__atc_external_url = os.environ["ATC_EXTERNAL_URL"]

        # Verify configuration is valid
        if not self.__config.is_valid_source_config():
            raise UpdaterError("Source configuration is not valid")
        if not self.__config.is_valid_put_config():
            raise UpdaterError("Put configuration is not valid")

        # Initialize Git server object
        if self.__config.get("server_type", source="source") == "Bitbucket":
            self.__git_server = BitbucketServerAPI(
                server_url=self.__config.get("server_url", source="source"),
                access_token=self.__config.get("access_token", source="source")
            )
        else:
            raise UpdaterError("Unsupported server type '{server_type}' provided".format(
                server_type=self.__config.get("server_type", source="source")
            ))


    def __get_file_contents(self, filename):

        with open(filename) as input_file:
            contents = input_file.read().strip()
        return contents


    def put(self):

        base_path = os.path.join(self.__destination, self.__config.get("path", source="params"))
        pull_request_id = self.__get_file_contents(os.path.join(base_path, "pull_request_id"))
        pull_request_commit_id = self.__get_file_contents(os.path.join(base_path, "pull_request_commit_id"))
        pull_request_update_date = self.__get_file_contents(os.path.join(base_path, "pull_request_update_date"))

        build_state = self.__config.get("state", source="params")
        if build_state.upper() not in ["INPROGRESS", "SUCCESSFUL", "FAILED"]:
            raise UpdaterError(f"Unsupported state '{build_state}' provided")

        build_key = "{build_team_name}|{build_pipeline_name}|{build_job_name}".format(
            build_team_name=self.__build_team_name,
            build_pipeline_name=self.__build_pipeline_name,
            build_job_name=self.__build_job_name
        )
        build_url = "{atc_external_url}/teams/{build_team_name}/pipelines/{build_pipeline_name}/jobs/{build_job_name}/builds/{build_name}".format(
            atc_external_url=self.__atc_external_url,
            build_team_name=self.__build_team_name,
            build_pipeline_name=self.__build_pipeline_name,
            build_job_name=self.__build_job_name,
            build_name=self.__build_name
        )
        build_link_text = "Pipeline {build_pipeline_name} | Job {build_job_name} | Build #{build_name}".format(
            build_pipeline_name=self.__build_pipeline_name,
            build_job_name=self.__build_job_name,
            build_name=self.__build_name
        )
        build_description = "Build for Commit {commit_id}".format(commit_id=pull_request_commit_id)

        self.__git_server.update_commit_build_status(
            commit_id=pull_request_commit_id,
            state=build_state,
            key=build_key,
            name=build_link_text,
            url=build_url,
            description=build_description
        )

        updater_results = {
            "version": {
                "id": pull_request_id,
                "ref": pull_request_commit_id,
                "date": pull_request_update_date
            },
            "metadata": []
        }

        return updater_results

