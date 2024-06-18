*Copyright (C) 2021, Axis Communications AB, Lund, Sweden. All Rights Reserved.*

<!-- omit in toc -->
# Telemetry to AWS IoT Core

[![Build telemetry-to-aws-iot-core](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/telemetry-to-aws-iot-core.yml/badge.svg)](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/telemetry-to-aws-iot-core.yml)
[![Lint codebase](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/lint.yml/badge.svg)](https://github.com/AxisCommunications/acap-integration-examples-aws/actions/workflows/lint.yml)
![Ready for use in production](https://img.shields.io/badge/Ready%20for%20use%20in%20production-Yes-brightgreen)

This directory hosts the necessary code to follow the instructions detailed in [Send telemetry to AWS IoT Core](https://developer.axis.com/analytics/how-to-guides/send-telemetry-to-aws-iot-core) on Axis Developer Documentation.

## File structure

<!-- markdownlint-disable MD040 -->
```
telemetry-to-aws-iot-core
├── create-cloud-resources.sh - Bash script that creates AWS resources and certificates for secure communication between camera and cloud
└── template.yaml - AWS CloudFormation template describing the AWS resources
```

## License

[Apache 2.0](./LICENSE)
