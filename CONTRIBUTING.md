# How to make a contribution

This page addresses the guidelines for the following actions below.

- How to clone the repository on your local machine
- How to make a good Pull Request (PR)
- How to post an issue in the issue tracker

## How to clone the repository on your local machine

Please use the following commands to clone the examples repository on your local machine.

**Fork it from GitHub GUI**

Start by [forking the repository](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)

**Clone it**

```bash
$ git clone https://github.com/<your username>/acap-integration-examples-aws.git
```

**Create your feature branch**

```bash
$ git checkout -b <branch name>
```

**Commit your changes**

```bash
$ git commit -a -m 'Follow the conventional commit messages style to write this message'
```

**Push to the branch**

```bash
$ git push origin <branch name>
```

**Make a Pull request from GitHub GUI**

## How to make a good Pull Request (PR)

Please consider the following guidelines before making a Pull Request.

- Please make sure that the sample code builds perfectly fine on your local system.
- Follow the [conventional commits](https://www.conventionalcommits.org) message style in the commit messages.
- The PR will have to meet the sample code examples standard already available in the repository.
- Explanatory comments related to code functions are required. Please write code comments for a better understanding of the code for other developers.
- No PR will be accepted without having a well defined README (see examples in the repo) file for the sample code.

## How to post an issue in the issue tracker

Please follow the guidelines below before posting an issue in the issue tracker.

- Axis Camera model (e.g., MQ1615) used when running the examples
- Firmware version installed on the camera
- Error(s) showed during building or running the example
