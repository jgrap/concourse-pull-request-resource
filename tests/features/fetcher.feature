Feature: Concourse Resource Get Functionality


    Scenario: Check with Missing Config
        Given the resource config of
            """
            {
                "source": {}
            }
            """
          And a mock destination from Concourse of /tmp
          And a mock response from Bitbucket for pull request of
            """
            {}
            """
          And a mock response from Bitbucket for commit of
            """
            {}
            """
         When fetching the pull request
         Then the get should have encountered an error


    Scenario: Get Pull Request from Supplied Version
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                },
                "version": {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                }
            }
            """
          And a mock destination from Concourse of /tmp
          And a mock response from Bitbucket for pull request of
            """
            {
                "id": 1,
                "version": 1,
                "updatedDate": 1598480978217,
                "title": "Pull Request Title",
                "fromRef": {
                    "displayId": "pr-branch-name",
                    "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                },
                "toRef": {
                    "displayId": "master",
                    "latestCommit": "kqgmdyo1bj5mx2lgr5lulwwdysrg9ei8808zqdfu"
                },
                "author": {
                    "user": {
                        "displayName": "John Doe"
                    }
                }
            }
            """
          And a mock response from Bitbucket for commit of
            """
            {
                "id": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                "committer": {
                    "displayName": "John Doe"
                },
                "committerTimestamp": 1599002385000,
                "message": "Commit message from John Doe"
            }
            """
          And a mock response from Bitbucket for commit of
            """
            {
                "id": "kqgmdyo1bj5mx2lgr5lulwwdysrg9ei8808zqdfu",
                "committer": {
                    "displayName": "Jane Doe"
                },
                "committerTimestamp": 1599002384331,
                "message": "Commit message from Jane Doe"
            }
            """
         When fetching the pull request
         Then the get result should match the following
            """
            {
                "version": {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                },
                "metadata": [
                    {
                        "name": "id",
                        "value": "1"
                    },
                    {
                        "name": "title",
                        "value": "Pull Request Title"
                    },
                    {
                        "name": "author",
                        "value": "John Doe"
                    },
                    {
                        "name": "repository",
                        "value": "repository"
                    },
                    {
                        "name": "source_commit",
                        "value": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    {
                        "name": "source_author",
                        "value": "John Doe"
                    },
                    {
                        "name": "source_commit_date_utc",
                        "value": "2020/09/01 23:19:45"
                    },
                    {
                        "name": "source_message",
                        "value": "Commit message from John Doe"
                    },
                    {
                        "name": "target_commit",
                        "value": "kqgmdyo1bj5mx2lgr5lulwwdysrg9ei8808zqdfu"
                    },
                    {
                        "name": "target_author",
                        "value": "Jane Doe"
                    },
                    {
                        "name": "target_commit_date_utc",
                        "value": "2020/09/01 23:19:44"
                    },
                    {
                        "name": "target_message",
                        "value": "Commit message from Jane Doe"
                    }
                ]
            }
            """
          And the get file pull_request_id should contain 1
          And the get file pull_request_commit_id should contain 2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4
          And the get file pull_request_update_date should contain 1598480978217
