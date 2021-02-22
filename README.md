# Git Pull Request Resource

Concourse CI resource for monitoring and updating Git pull requests.

*_NOTE_: Currently only supports Bitbucket servers*

---

## Source Configuration

* `server_url`:        *Required.*  The URL for the Git server
* `server_type`: *Required.*  Must be _Bitbucket_.  Additional server types may be added in the future.
* `access_token`:      *Required.*  Access token for authenticating to Git server
  * See [Bitbucket Access Tokens](https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html) for more information on setting up Bitbucket access tokens
* `project`:   *Required.*  Git project name
* `repository`:   *Required.*  Git repository within project
* `paths`:     *Optional.*  List of paths within Git repository to monitor for changes.  Supports glob syntax

---

## `check`: Check for new pull request commits

Checks for new pull requests or updates to existing pull requests.

---

## `in`: Clones pull request commit

Clones the pull request and creates files `pull_request_id`, `pull_request_commit_id`, and `pull_request_update_date`.

---

## `out`: Update pull request build status

Updates the pull request build status.

### Configuration

* `path`: *Required.*  Path to directory containing necessary pull request information.  Should always be the same resource as used for get step.

* `state`: *Required.*  Pull request build state.  Valid options: `inprogress`, `successful`, `failed`

---

## Examples

Example Resource Configuration

``` yaml
resource_types:

  - name: pull-request-resource
    type: docker-image
    source:
      repository: docker.mot-solutions.com/msi/console-arcus/utilities/concourse/pull-request-resource
      tag: 0.1.0-pre
      username: <username for image repository>
      password: <password for image repository>

resources:

  - name: testing.pull-request
    type: pull-request-resource
    check_every: 300s
    source:
      server_url: https://<bitbucket server URL>
      server_type: Bitbucket
      access_token: <access token>
      project: <project name>
      repository: <repository name>
      paths:
        - dir/*
```

Performing a build, updating status based on results

``` yaml
jobs:

  - name: Build
    serial: true
    plan:
      - get: testing.pull-request
        version: every
        trigger: true
      - put: testing.pull-request
        params:
          path: testing.pull-request
          state: INPROGRESS
      - task: Perform Build
        config:
          platform: linux
          image_resource:
            type: registry-image
            source:
              repository: busybox
          inputs:
            - name: testing.pull-request
          run:
            dir: testing.pull-request
            path: /bin/sh
            args:
              - -c
              - |
                ./build.sh
    on_success:
      - put: testing.pull-request
        params:
          path: testing.pull-request
          state: SUCCESSFUL
    on_failure:
      - put: testing.pull-request
        params:
          path: testing.pull-request
          state: FAILED
```