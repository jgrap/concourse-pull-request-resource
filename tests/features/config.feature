Feature: Concourse Resource Config Verification

    Scenario: Complete Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         Then the source config is valid


    Scenario: Missing 'server_url' Source Config
        Given the resource config of
            """
            {
                "source": {
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         Then the source config is invalid


    Scenario: Missing 'access_token' Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         Then the source config is invalid


    Scenario: Missing 'project' Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         Then the source config is invalid


    Scenario: Missing 'repository' Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "server_type": "Bitbucket"
                }
            }
            """
         Then the source config is invalid


    Scenario: Missing 'server_type' Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository"
                }
            }
            """
         Then the source config is invalid


    Scenario: Missing Source Config
        Given the resource config of
            """
            {
                "source": {}
            }
            """
         Then the source config is invalid


    Scenario: Get Source Config Object
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         When requesting config object with key source
         Then the retrieved config object should be
            """
            {
                "server_url": "https://localhost:10342",
                "access_token": "8fds01jhMW",
                "project": "project",
                "repository": "repository",
                "server_type": "Bitbucket"
            }
            """


    Scenario: Get Nonexisting Version Config Object
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         When requesting config object with key version
         Then the retrieved config object shouldn't exist


    Scenario: Get Server URL from Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         When requesting config item from source source with key server_url
         Then the retrieved config item should be https://localhost:10342


    Scenario: Get Nonexisting 'repo' Item from Source Config
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         When requesting config item from source source with key repo
         Then the retrieved config item shouldn't exist


    Scenario: Get 'ref' from Nonexisting Version Object
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket"
                }
            }
            """
         When requesting config item from source version with key ref
         Then the retrieved config item shouldn't exist
