#!/usr/bin/env python3

import os
import requests
from abc import ABC, abstractmethod     # ABC = Abstract Base Class
from pathlib import Path


class GitServerAPIInterface(ABC):

    @abstractmethod
    def get_pull_requests(self):
        pass

    @abstractmethod
    def get_pull_request(self):
        pass

    @abstractmethod
    def get_pull_request_changes(self):
        pass

    @abstractmethod
    def get_pull_request_commits(self):
        pass

    @abstractmethod
    def get_repository_archive(self):
        pass


class BitbucketServerAPI(GitServerAPIInterface):

    def __init__(self, server_url, access_token):

        self.__server_url = server_url
        self.__access_token = access_token

        # Base URLs for various Bitbucket APIs
        self.__server_core_base_url = f"{server_url}/rest/api/1.0"
        self.__server_build_base_url = f"{server_url}/rest/build-status/1.0"

        # Core REST API endpoints
        self.__repository_pullrequests_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/pull-requests"
        self.__repository_pullrequest_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/pull-requests/{{pull_request_id}}"
        self.__repository_pullrequest_activities_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/pull-requests/{{pull_request_id}}/activities"
        self.__repository_pullrequest_changes_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/pull-requests/{{pull_request_id}}/changes"
        self.__repository_pullrequest_commits_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/pull-requests/{{pull_request_id}}/commits"
        self.__repository_commit_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/commits/{{commit_id}}"
        self.__repository_archive_endpoint = f"{self.__server_core_base_url}/projects/{{project}}/repos/{{repository}}/archive"

        # Build REST API endpoints
        self.__commit_build_status_endpoint = f"{self.__server_build_base_url}/commits/{{commit_id}}"


    def __get_headers(self):
        return {
            "Authorization": "Bearer {access_token}".format(access_token=self.__access_token)
        }


    def get_pull_requests(self, project, repository):
        """
        NOTE: Bitbucket returns this list of PRs sorted from most recently updated to
              least recently updated
        """

        uri = self.__repository_pullrequests_endpoint.format(project=project, repository=repository)
        response = requests.get(uri, headers=self.__get_headers())
        response.raise_for_status()

        pull_requests = response.json()["values"]

        return pull_requests


    def get_pull_request(self, project, repository, pull_request_id):

        uri = self.__repository_pullrequest_endpoint.format(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id
        )
        response = requests.get(uri, headers=self.__get_headers())
        response.raise_for_status()

        pull_request = response.json()

        return pull_request


    # I must handle paging on this one...  Should check others...
    def get_pull_request_changes(self, project, repository, pull_request_id, start_commit_id, end_commit_id):

        uri = self.__repository_pullrequest_changes_endpoint.format(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id
        )
        params = {
            "changeScope": "RANGE",
            "sinceId": start_commit_id,
            "untilId": end_commit_id,
            "withComments": False
        }

        response = requests.get(uri, headers=self.__get_headers(), params=params)
        response.raise_for_status()

        pull_request_changes = response.json()["values"]

        return pull_request_changes


    # I must handle paging on this one...  Should check others...
    def get_pull_request_commits(self, project, repository, pull_request_id):

        uri = self.__repository_pullrequest_commits_endpoint.format(
            project=project,
            repository=repository,
            pull_request_id=pull_request_id
        )

        response = requests.get(uri, headers=self.__get_headers())
        response.raise_for_status()

        pull_request_commits = response.json()["values"]

        return pull_request_commits


    def get_repository_archive(self, project, repository, commit_id, output_dir, archive_format="tar.gz"):

        uri = self.__repository_archive_endpoint.format(project=project, repository=repository)
        params = {
            "at": commit_id,
            "format": archive_format
        }
        response = requests.get(uri, headers=self.__get_headers(), params=params)
        response.raise_for_status()

        output_archive = Path(f"{output_dir}/{commit_id}.tar.gz")
        with output_archive.open("wb") as output_file:
            output_file.write(response.content)

        return output_archive


    def get_commit(self, project, repository, commit_id):

        uri = self.__repository_commit_endpoint.format(
            project=project,
            repository=repository,
            commit_id=commit_id
        )
        response = requests.get(uri, headers=self.__get_headers())
        response.raise_for_status()

        commit = response.json()

        return commit


    def get_commit_build_status(self, commit_id):

        uri = self.__commit_build_status_endpoint.format(commit_id=commit_id)

        response = requests.get(uri, headers=self.__get_headers())
        response.raise_for_status()

        paged_response = response.json()
        values = paged_response["values"]

        while not paged_response["isLastPage"]:

            params = {
                "start": paged_response["nextPageStart"]
            }
            response = requests.get(uri, headers=self.__get_headers(), params=params)
            response.raise_for_status()

            paged_response = response.json()
            values.extend(paged_response["values"])

        return values


    def update_commit_build_status(self, commit_id, state, key, name, url, description):

        uri = self.__commit_build_status_endpoint.format(commit_id=commit_id)
        body = {
            "state": state.upper(),
            "key": key,
            "name": name,
            "url": url,
            "description": description
        }
        response = requests.post(uri, headers=self.__get_headers(), json=body)
        response.raise_for_status()
