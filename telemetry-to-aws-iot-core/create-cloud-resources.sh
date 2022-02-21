#!/bin/bash
set -e

if [[ $# -ne 2 ]]; then
  echo "Error: Unsupported number of arguments"
  echo
  echo "USAGE:"
  echo "    create-cloud-resources.sh <stack name> <thing name>"
  echo
  echo "WHERE:"
  echo "    stack name      The name of the CloudFormation stack, e.g."
  echo "                    axis-device-telemetry"
  echo "    thing name      The name of the IoT Core Thing, e.g. device01"
  echo

  exit 1
fi

stack_name=$1
thing_name=$2

# Directory where we store certificates
cert_directory=./cert

# Path to the Amazon root CA certificate
ca_cert_path=$cert_directory/AmazonRootCA1.pem

# Paths to the principal certificate
principal_cert_path=$cert_directory/$thing_name.crt
principal_key_path=$cert_directory/$thing_name.key
principal_cert_id_path=$cert_directory/$thing_name-id.txt

# Pipe AWS CLI output to stdout
export AWS_PAGER=

get_certificate_arn() {
  resp=$(
    aws iot describe-certificate \
      --certificate-id $(cat $principal_cert_id_path) \
      --query certificateDescription.certificateArn \
      --output text 2>&1
    exit 0
  )
}

# -----------------------------------------------------------------------------
# CREATE CERTIFICATES
# -----------------------------------------------------------------------------

mkdir -p $cert_directory

# We want to use X.509 certificates to authenticate our camera to AWS IoT Core, and the first step
# is to download the AWS CA certificate to a new directory called 'cert'.
if [ ! -f "$ca_cert_path" ]; then
  echo "Downloading Amazon root CA certificate..."
  curl -s https://www.amazontrust.com/repository/AmazonRootCA1.pem >$ca_cert_path
  echo "    $ca_cert_path"
fi

# Next we will create a new certificate in AWS IoT Core, acting as the principal identity for the
# AWS IoT Core Thing.
if [ -f "$principal_cert_id_path" ]; then
  get_certificate_arn

  if [[ "$resp" == *"error"* ]]; then
    echo "Previously created principal certificate was not found in AWS, let's re-create it"
  else
    echo "Previously created principal certificate was found in AWS, let's reuse it"
    principal_cert_arn=$resp
  fi
fi

if [ -z "$principal_cert_arn" ]; then
  echo "Create principal certificate..."

  aws iot create-keys-and-certificate \
    --set-as-active \
    --certificate-pem-outfile $principal_cert_path \
    --private-key-outfile $principal_key_path \
    --output text \
    --query certificateId \
    >$principal_cert_id_path

  get_certificate_arn
  principal_cert_arn=$resp

  echo "    $principal_cert_path"
  echo "    $principal_key_path"
fi

# -----------------------------------------------------------------------------
# PROVISION AWS RESOURCES
# -----------------------------------------------------------------------------

# At this point we are ready to deploy the AWS CloudFormation template defined in `template.yaml`.
echo "Deploy AWS CloudFormation template..."
aws cloudformation deploy \
  --stack-name $stack_name \
  --template-file template.yaml \
  --parameter-overrides ThingName=$thing_name CertificateArn=$principal_cert_arn

# The final step is to query AWS IoT Core for the data endpoint.
endpointAddress=$(aws iot describe-endpoint \
  --endpoint-type iot:Data-ATS \
  --query endpointAddress \
  --output text)

# -----------------------------------------------------------------------------
# OUTPUT
# -----------------------------------------------------------------------------

echo
echo "Done!"
echo
echo "The following settings will be used when configuring the camera."
echo
echo "MQTT Client Configuration"
echo "Host:       $endpointAddress"
echo "Client id:  $thing_name"
echo
