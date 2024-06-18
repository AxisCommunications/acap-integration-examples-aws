*Copyright (C) 2021, Axis Communications AB, Lund, Sweden. All Rights Reserved.*

<!-- omit in toc -->
# Sending images from a camera to AWS S3

[![Build images-to-aws-s3](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/images-to-aws-s3.yml/badge.svg)](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/images-to-aws-s3.yml)
[![Lint codebase](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/lint.yml/badge.svg)](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/lint.yml)
![Ready for use in production](https://img.shields.io/badge/Ready%20for%20use%20in%20production-Yes-brightgreen)

This directory hosts the necessary code to follow the instructions detailed in [Send images to AWS S3](https://developer.axis.com/computer-vision/how-to-guides/send-images-to-aws-s3) on Axis Developer Documentation.

## File structure

<!-- markdownlint-disable MD040 -->
```
images-to-aws-s3
├── src
│   ├── authorizer - Contains code authorizing requests to AWS API Gateway
│   │   ├── env.js - Exports environment variables
│   │   ├── index.js - Exports the AWS Lambda authorizer function
│   │   └── secrets.js - Exports a function capable of reading the access token from AWS Secrets Manager
│   └── upload-to-s3 - Contains code uploading images to AWS S3
│       ├── env.js - Exports environment variables
│       ├── index.js - Exports the AWS Lambda handler function
│       └── response.js - Exports common HTTP responses
├── .npmignore - npm package ignore file
├── package-lock.json - npm package lock file
├── package.json - npm package
└── template.yaml - AWS SAM template describing the AWS resources
```

## License

[Apache 2.0](./LICENSE)
