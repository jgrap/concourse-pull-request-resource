Feature: Concourse Resource Put Functionality

    # TODO: Make more robust / tailored toward put (missing params)
    Scenario: Put with Missing Config
        Given the resource config of
            """
            {
                "source": {}
            }
            """
          And a mock destination from Concourse of /tmp
         When updating the pull request
         Then the put should have encountered an error


    # There is only limited coverage here, as the response from updating the PR
    # cannot be truly tested.  Tested manually with Bitbucket server instance
    # TODO: Handle basic error scenarios for bad states provided
    Scenario: Update Pull Request
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
                "params": {
                    "path": "/tmp",
                    "state": "SUCCESSFUL"
                }
            }
            """
          And a mock destination from Concourse of /tmp
          And the put file pull_request_id contains 1
          And the put file pull_request_commit_id contains 2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4
          And the put file pull_request_update_date contains 1598480978217
         When updating the pull request
         Then the put result should match the following
            """
            {
                "version": {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                },
                "metadata": []
            }
            """