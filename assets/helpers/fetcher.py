#!/usr/bin/env python3

import os
import sys
import json
import tarfile
from pathlib import Path
from datetime import datetime, timezone

from .config import Config
from .git_server import BitbucketServerAPI


class FetcherError(Exception):
    """
    Exception class raised for Fetcher errors

    Attributes:
        message (string)    Fetcher error message
    """

    def __init__(self, message):
        self.message = message


class Fetcher:
    """
    Class for handling get functionality for Concourse resource

    Attributes:
        __config       (dict)  Concourse resource configuration
        __destination  (Path)  Output directory to hold fetched Git repository
    """

    def __init__(self):

        self.__config = Config(config=json.loads(sys.stdin.read()))
        self.__destination = Path(sys.argv[1])

        # Verify configuration is valid
        if not self.__config.is_valid_source_config():
            raise FetcherError("Source configuration is not valid")
        if not self.__config.is_valid_get_config():
            raise FetcherError("Get configuration is not valid")

        # Initialize Git server object
        if self.__config.get("server_type", source="source") == "Bitbucket":
            self.__git_server = BitbucketServerAPI(
                server_url=self.__config.get("server_url", source="source"),
                access_token=self.__config.get("access_token", source="source")
            )
        else:
            raise FetcherError("Unsupported server type '{server_type}' provided".format(
                server_type=self.__config.get("server_type", source="source")
            ))


    def __write_file_contents(self, filename, contents):

        filename = os.path.join(self.__destination, filename)
        with open(filename, "w") as output_file:
            output_file.write(contents)


    def get_archive(self, project, repository, commit_id):

        archive = self.__git_server.get_repository_archive(
            project=project,
            repository=repository,
            commit_id=commit_id,
            output_dir=self.__destination
        )

        with tarfile.open(str(archive)) as input_file:
            input_file.extractall(path=self.__destination)
        archive.unlink()


    def get_date_from_timestamp(self, timestamp):

        date = datetime.fromtimestamp(int(timestamp / 1000), tz=timezone.utc)
        return date.strftime(r"%Y/%m/%d %H:%M:%S")


    def get(self):

        project = self.__config.get_config()["source"]["project"]
        repository = self.__config.get_config()["source"]["repository"]
        pull_request_id = self.__config.get_config()["version"]["id"]
        pull_request_commit_id = self.__config.get_config()["version"]["ref"]
        pull_request_update_date = self.__config.get_config()["version"]["date"]

        upstream_pull_request = self.__git_server.get_pull_request(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id
        )

        pull_request_author = upstream_pull_request["author"]["user"]["displayName"]
        pull_request_branch = upstream_pull_request["fromRef"]["displayId"]
        pull_request_title = upstream_pull_request["title"]
        target_branch = upstream_pull_request["toRef"]["displayId"]
        target_commit_id = upstream_pull_request["toRef"]["latestCommit"]

        source_commit = self.__git_server.get_commit(
            project=project,
            repository=repository,
            commit_id=pull_request_commit_id
        )

        target_commit = self.__git_server.get_commit(
            project=project,
            repository=repository,
            commit_id=target_commit_id
        )

        source_commit_author = source_commit["committer"]["displayName"]
        source_commit_date = self.get_date_from_timestamp(int(source_commit["committerTimestamp"]))
        source_commit_message = source_commit["message"]
        target_commit_author = target_commit["committer"]["displayName"]
        target_commit_date = self.get_date_from_timestamp(int(target_commit["committerTimestamp"]))
        target_commit_message = target_commit["message"]

        self.get_archive(project, repository, pull_request_commit_id)

        self.__write_file_contents("pull_request_id", pull_request_id)
        self.__write_file_contents("pull_request_commit_id", pull_request_commit_id)
        self.__write_file_contents("pull_request_update_date", pull_request_update_date)

        get_results = {
            "version": self.__config.get_config()["version"],
            "metadata": [
                {
                    "name": "id",
                    "value": pull_request_id
                },
                {
                    "name": "title",
                    "value": pull_request_title
                },
                {
                    "name": "author",
                    "value": pull_request_author
                },
                {
                    "name": "repository",
                    "value": repository
                },
                {
                    "name": "source_commit",
                    "value": pull_request_commit_id
                },
                {
                    "name": "source_author",
                    "value": source_commit_author
                },
                {
                    "name": "source_commit_date_utc",
                    "value": source_commit_date
                },
                {
                    "name": "source_message",
                    "value": source_commit_message
                },
                {
                    "name": "target_commit",
                    "value": target_commit_id
                },
                {
                    "name": "target_author",
                    "value": target_commit_author
                },
                {
                    "name": "target_commit_date_utc",
                    "value": target_commit_date
                },
                {
                    "name": "target_message",
                    "value": target_commit_message
                }
            ]
        }

        return get_results
