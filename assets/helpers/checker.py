#!/usr/bin/env python3

import sys
import json
from datetime import datetime, timedelta
from pathlib import Path
from fnmatch import fnmatch

from .config import Config
from .git_server import BitbucketServerAPI


class CheckerError(Exception):
    """
    Exception class raised for Checker errors

    Attributes:
        message (string)    Checker error message
    """

    def __init__(self, message):
        self.message = message


class Checker:
    """
    Class for handling check functionality for Concourse resource

    Attributes:
        __config        (dict)              Concourse resource configuration
        __git_server    (GitServer object)  Object for interacting with the git server
    """

    def __init__(self):

        self.__config = Config(config=json.loads(sys.stdin.read()))

        # Verify configuration is valid
        if not self.__config.is_valid_source_config():
            raise CheckerError("Source configuration is not valid")

        # Initialize Git server object
        if self.__config.get("server_type", source="source") == "Bitbucket":
            self.__git_server = BitbucketServerAPI(
                server_url=self.__config.get("server_url", source="source"),
                access_token=self.__config.get("access_token", source="source")
            )
        else:
            raise CheckerError("Unsupported server type '{server_type}' provided".format(
                server_type=self.__config.get("server_type", source="source")
            ))


    def __check_paths_match(self, project, repository, pull_request_id, commit_id):

        patterns = self.__config.get("paths", source="source")
        if patterns is None:
            return True

        commits = self.__git_server.get_pull_request_commits(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id
        )

        starting_commit = commits[-1]["parents"][0]["id"]

        changes = self.__git_server.get_pull_request_changes(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id,
            start_commit_id=starting_commit,
            end_commit_id=commit_id
        )

        match = False
        for change in changes:
            for pattern in patterns:
                if fnmatch(change["path"]["toString"], pattern):
                    match = True
                    break

        return match


    def check(self):

        project = self.__config.get("project", source="source")
        repository = self.__config.get("repository", source="source")

        upstream_pull_requests = self.__git_server.get_pull_requests(
            project=project,
            repository=repository
        )

        # Bitbucket returns the list of pull requests in the order of most recently updated to
        # the least recently updated;  start from least recently updated
        upstream_pull_requests.reverse()

        # Check for current version in config payload
        if self.__config.get("version") == None:
            check_results = []
            for pull_request in upstream_pull_requests:
                # Pull out important information
                pull_request_id = pull_request["id"]
                pull_request_commit_id = pull_request["fromRef"]["latestCommit"]
                pull_request_merge_status = pull_request["properties"]["mergeResult"]["outcome"]
                pull_request_update_date = pull_request["updatedDate"]
                # Skip pull requests that have conflicts
                if pull_request_merge_status == "CONFLICTED":
                    continue
                # Skip pull requests that do not match supplied paths
                if not self.__check_paths_match(project=project, repository=repository, pull_request_id=pull_request_id, commit_id=pull_request_commit_id):
                    continue
                # Add least recently updated pull request without conflicts
                # and return it to Concourse
                check_results.append({
                    "id": str(pull_request_id),
                    "ref": pull_request_commit_id,
                    "date": str(pull_request_update_date)
                })
                break
        else:
            # Since it is not unlikely that a pull request will no longer exist on the next check,
            # to keep a good history, add the version automatically
            check_results = [ self.__config.get("version") ]
            current_version_update_date = self.get_date_from_timestamp(int(self.__config.get("date", source="version")))
            for pull_request in upstream_pull_requests:
                # Pull out important information
                pull_request_id = pull_request["id"]
                pull_request_commit_id = pull_request["fromRef"]["latestCommit"]
                pull_request_merge_status = pull_request["properties"]["mergeResult"]["outcome"]
                pull_request_update_date = pull_request["updatedDate"]
                # Skip pull requests that have conflicts
                if pull_request_merge_status == "CONFLICTED":
                    continue
                # Skip pull requests that do not match supplied paths
                if not self.__check_paths_match(project=project, repository=repository, pull_request_id=pull_request_id, commit_id=pull_request_commit_id):
                    continue
                # Check update date as means of determining a new version
                if self.get_date_from_timestamp(pull_request_update_date) > current_version_update_date:
                    check_results.append({
                        "id": str(pull_request_id),
                        "ref": pull_request_commit_id,
                        "date": str(pull_request_update_date)
                    })

        return check_results


    def get_config(self):
        return self.__config.get_config()


    def get_date_from_timestamp(self, timestamp):
        timestamp_seconds = timestamp // 1000
        timestamp_milliseconds = timestamp % 1000
        return datetime.fromtimestamp(timestamp_seconds) + timedelta(milliseconds=timestamp_milliseconds)
