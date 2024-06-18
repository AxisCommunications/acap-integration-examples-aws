*Copyright (C) 2021, Axis Communications AB, Lund, Sweden. All Rights Reserved.*

<!-- omit in toc -->
# This repository has been archived, and its content moved to [Axis Developer Documentation](https://developer.axis.com/)

# Integration between Axis devices and Amazon Web Services (AWS)

## Introduction

[AXIS Camera Application Platform (ACAP)](https://www.axis.com/support/developer-support/axis-camera-application-platform) is an open platform that enables developer to build applications that can be installed on Axis network cameras and video encoders.

[Amazon Web Services (AWS)](https://aws.amazon.com) is a platform in the cloud that provides highly reliable, scalable, low-cost infrastructure to individuals, companies, and governments.

This repository focuses on providing examples where we create the integration between the Axis device and Amazon Web Services. If you are interested in camera applications and the different API surfaces an application can use, please visit our related repository [AxisCommunications/acap3-examples](https://github.com/AxisCommunications/acap3-examples/).

## Example applications

The repository contains a set of examples, each tailored towards a specific problem. All examples have a README file in its directory which shows overview, example directory structure and step-by-step instructions on how to deploy the AWS infrastructure and how to configure the camera to interact with AWS.

If you find yourself wishing there was another example more relevant to your use case, please don't hesitate to [start a discussion](https://github.com/AxisCommunications/acap-integration-examples-aws/discussions/new) or [open a new issue](https://github.com/AxisCommunications/acap-integration-examples-aws/issues/new/choose).

- [images-to-aws-s3](./images-to-aws-s3/)
    - This example covers sending images from a camera to AWS S3
- [telemetry-to-aws-iot-core](./telemetry-to-aws-iot-core/)
    - This example covers sending telemetry from a camera to AWS IoT Core

## License

[Apache 2.0](./LICENSE)
