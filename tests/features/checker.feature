Feature: Concourse Resource Check Functionality


    Scenario: Check with Missing Config
        Given the resource config of
            """
            {
                "source": {}
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            []
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check should have encountered an error


    Scenario: Check without Current Version, No Open Pull Requests
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
          And a mock response from Bitbucket for pull requests of
            """
            []
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            []
            """


    Scenario: Check without Current Version, Single Open Pull Request
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                }
            ]
            """


    Scenario: Check without Current Version, Multiple Open Pull Requests
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 2,
                    "updatedDate": 1598480978210,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978210"
                }
            ]
            """


    Scenario: Check with Current Version, No New Open Pull Requests
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
                    "date": "1598480978210"
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978210,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978210"
                }
            ]
            """


    Scenario: Check with Current Version, Current Version No Longer Exists
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
                    "date": "1598480978210"
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            []
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978210"
                }
            ]
            """


    Scenario: Check with Current Version, New Commit to Existing Pull Request
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
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978210"
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 2,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978210"
                },
                {
                    "id": "2",
                    "ref": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw",
                    "date": "1598480978217"
                }
            ]
            """


    Scenario: Check with Current Version, New Open Pull Request
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 2,
                    "updatedDate": 1598480978300,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                },
                {
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978300"
                }
            ]
            """


    Scenario: Check with Current Version, Multiple New Open Pull Request
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 3,
                    "updatedDate": 1598480978444,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 2,
                    "updatedDate": 1598480978354,
                    "fromRef": {
                        "latestCommit": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                },
                {
                    "id": "2",
                    "ref": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw",
                    "date": "1598480978354"
                },
                {
                    "id": "3",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978444"
                }
            ]
            """


    Scenario: Check with Current Version, Previous Pull Request No Longer Open
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
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978217"
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            []
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978217"
                }
            ]
            """
          Given a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978300,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 2,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "2",
                    "ref": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn",
                    "date": "1598480978217"
                },
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978300"
                }
            ]
            """


    Scenario: Check with Current Version, New Open Pull Requests with Merge Conflicts
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 3,
                    "updatedDate": 1598480978400,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CONFLICTED"
                        }
                    }
                },
                {
                    "id": 2,
                    "updatedDate": 1598480978333,
                    "fromRef": {
                        "latestCommit": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                },
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                },
                {
                    "id": "2",
                    "ref": "ewhk7zmjzxxl2obqcu7ywa2tvv48xmgymra7p9bw",
                    "date": "1598480978333"
                }
            ]
            """


    Scenario: Check with Current Version, New Commits for Existing Pull Request with Merge Conflicts
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
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978333,
                    "fromRef": {
                        "latestCommit": "0xacmxhtx7nkgai4lbna1z2qifgne0kcl6hf3htn"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CONFLICTED"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            []
            """
          And a mock response from Bitbucket for pull request changes of
            """
            []
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                }
            ]
            """


    Scenario: Check without Current Version, Single Open Pull Request, Paths Match
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket",
                    "paths": [
                        "*file*"
                    ]
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            [
                {
                    "id": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "parents": [
                        {
                            "id": "3f446198f71979dbd2c364d679af596073336ea9"
                        }
                    ]
                },
                {
                    "id": "3f446198f71979dbd2c364d679af596073336ea9",
                    "parents": [
                        {
                            "id": "732b7a9ba41df7331ebdcd58895d1d112fd4458f"
                        }
                    ]
                }
            ]
            """
          And a mock response from Bitbucket for pull request changes of
            """
            [
                {
                    "path": {
                        "toString": "file1"
                    }
                }
            ]
            """
         When checking for new versions
         Then the check result should match the following
            """
            [
                {
                    "id": "1",
                    "ref": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "date": "1598480978217"
                }
            ]
            """


    Scenario: Check without Current Version, Single Open Pull Request, Paths Don't Match
        Given the resource config of
            """
            {
                "source": {
                    "server_url": "https://localhost:10342",
                    "access_token": "8fds01jhMW",
                    "project": "project",
                    "repository": "repository",
                    "server_type": "Bitbucket",
                    "paths": [
                        "dir/*"
                    ]
                }
            }
            """
          And a mock response from Bitbucket for pull requests of
            """
            [
                {
                    "id": 1,
                    "updatedDate": 1598480978217,
                    "fromRef": {
                        "latestCommit": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4"
                    },
                    "properties": {
                        "mergeResult": {
                            "outcome": "CLEAN"
                        }
                    }
                }
            ]
            """
          And a mock response from Bitbucket for pull request commits of
            """
            [
                {
                    "id": "2ssivhnj5qzsulmp5km9l3kd6fvjkvwhzq4owao4",
                    "parents": [
                        {
                            "id": "3f446198f71979dbd2c364d679af596073336ea9"
                        }
                    ]
                },
                {
                    "id": "3f446198f71979dbd2c364d679af596073336ea9",
                    "parents": [
                        {
                            "id": "732b7a9ba41df7331ebdcd58895d1d112fd4458f"
                        }
                    ]
                }
            ]
            """
          And a mock response from Bitbucket for pull request changes of
            """
            [
                {
                    "path": {
                        "toString": "file1"
                    }
                }
            ]
            """
         When checking for new versions
         Then the check result should match the following
            """
            []
            """
