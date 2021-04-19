#!/bin/bash
set -e

if [[ $# -ne 5 ]]; then
  echo "Error: Unsupported number of arguments"
  echo
  echo "USAGE:"
  echo "    configure-camera.sh <address> <username> <password> <recipient> <access token>"
  echo
  echo "WHERE:"
  echo "    address         The IP address or hostname of the Axis camera"
  echo "    username        The username used when accessing the Axis camera"
  echo "    password        The password used when accessing the Axis camera"
  echo "    recipient       The URL of the AWS API Gateway, defined as a CloudFormation"
  echo "                    output parameter"
  echo "    access token    The access token authorizing requests, linked from a"
  echo "                    CloudFormation output parameter"

  exit 1
fi

address=$1
username=$2
password=$3
recipient=$4
access_token=$5

send_request() {
  local data=$1

  resp=$(curl \
    -s \
    -X POST \
    -u $username:$password \
    --digest \
    -H "Content-Type: application/xml" \
    -d "$data" \
    "http://$address/vapix/services")

  if [[ "$resp" == *"<html>"* ]]; then
    echo "Error: Request failed"
    echo
    echo "$resp"
    exit 1
  fi
}

echo "Adding recipient..."

send_request \
"<?xml version=\"1.0\" encoding=\"utf-8\"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\">
  <SOAP-ENV:Header/>
  <SOAP-ENV:Body xmlns:act=\"http://www.axis.com/vapix/ws/action1\">
    <act:AddRecipientConfiguration>
      <act:NewRecipientConfiguration>
        <act:Name>Images to AWS S3</act:Name>
        <act:TemplateToken>com.axis.recipient.https</act:TemplateToken>
        <act:Parameters>
          <act:Parameter Name=\"upload_url\" Value=\"$recipient\"/>
          <act:Parameter Name=\"validate_server_cert\" Value=\"1\"/>
          <act:Parameter Name=\"login\" Value=\"\"/>
          <act:Parameter Name=\"password\" Value=\"\"/>
          <act:Parameter Name=\"proxy_host\" Value=\"\"/>
          <act:Parameter Name=\"proxy_port\" Value=\"\"/>
          <act:Parameter Name=\"proxy_login\" Value=\"\"/>
          <act:Parameter Name=\"proxy_password\" Value=\"\"/>
          <act:Parameter Name=\"qos\" Value=\"0\"/>
        </act:Parameters>
      </act:NewRecipientConfiguration>
    </act:AddRecipientConfiguration>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

echo "Adding schedule..."

send_request \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\">
    <SOAP-ENV:Header/>
    <SOAP-ENV:Body xmlns:aev=\"http://www.axis.com/vapix/ws/event1\">
      <aev:AddScheduledEvent>
        <aev:NewScheduledEvent>
          <aev:Name>Images to AWS S3</aev:Name>
          <aev:Schedule>
            <aev:ICalendar Dialect=\"http://www.axis.com/vapix/ws/ical1\">DTSTART:19700101T000000
RRULE:FREQ=MINUTELY;INTERVAL=1</aev:ICalendar>
        </aev:Schedule>
      </aev:NewScheduledEvent>
    </aev:AddScheduledEvent>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

schedule_id=$(echo "$resp" | xpath -q -e '/SOAP-ENV:Envelope/SOAP-ENV:Body/aev:AddScheduledEventResponse/aev:EventID/text()')

echo "Adding rule..."

send_request \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\">
  <SOAP-ENV:Header/>
  <SOAP-ENV:Body xmlns:act=\"http://www.axis.com/vapix/ws/action1\">
    <act:AddActionConfiguration>
      <act:NewActionConfiguration>
        <act:Name>Send images through HTTPS</act:Name>
        <act:TemplateToken>com.axis.action.fixed.send_images.https</act:TemplateToken>
        <act:Parameters>
          <act:Parameter Name=\"stream_options\" Value=\"&amp;videocodec=jpeg&amp;audio=0&amp;camera=1\"/>
          <act:Parameter Name=\"pre_duration\" Value=\"0\"/>
          <act:Parameter Name=\"post_duration\" Value=\"3000\"/>
          <act:Parameter Name=\"max_images\" Value=\"1\"/>
          <act:Parameter Name=\"create_folder\" Value=\"\"/>
          <act:Parameter Name=\"filename\" Value=\"image%y-%m-%d_%H-%M-%S-%f_#s.jpg\"/>
          <act:Parameter Name=\"max_sequence_number\" Value=\"0\"/>
          <act:Parameter Name=\"custom_params\" Value=\"accessToken=$access_token\"/>
          <act:Parameter Name=\"validate_server_cert\" Value=\"1\"/>
          <act:Parameter Name=\"upload_url\" Value=\"$recipient\"/>
          <act:Parameter Name=\"qos\" Value=\"0\"/>
          <act:Parameter Name=\"login\" Value=\"\"/>
          <act:Parameter Name=\"password\" Value=\"\"/>
          <act:Parameter Name=\"proxy_host\" Value=\"\"/>
          <act:Parameter Name=\"proxy_port\" Value=\"\"/>
          <act:Parameter Name=\"proxy_login\" Value=\"\"/>
          <act:Parameter Name=\"proxy_password\" Value=\"\"/>
        </act:Parameters>
      </act:NewActionConfiguration>
    </act:AddActionConfiguration>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

action_id=$(echo "$resp" | xpath -q -e '/SOAP-ENV:Envelope/SOAP-ENV:Body/aa:AddActionConfigurationResponse/aa:ConfigurationID/text()')

send_request \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\">
  <SOAP-ENV:Header/>
  <SOAP-ENV:Body
    xmlns:act=\"http://www.axis.com/vapix/ws/action1\"
    xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\"
    xmlns:tns1=\"http://www.onvif.org/ver10/topics\"
    xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\">
    <act:AddActionRule>
      <act:NewActionRule>
        <act:Name>Images to AWS S3</act:Name>
        <act:Enabled>true</act:Enabled>
        <act:StartEvent>
          <wsnt:TopicExpression Dialect=\"http://docs.oasis-open.org/wsn/t-1/TopicExpression/Concrete\">tns1:UserAlarm/tnsaxis:Recurring/Pulse</wsnt:TopicExpression>
          <wsnt:MessageContent Dialect=\"http://www.onvif.org/ver10/tev/messageContentFilter/ItemFilter\">boolean(//SimpleItem[@Name=\"id\" and @Value=\"$schedule_id\"])</wsnt:MessageContent>
      	</act:StartEvent>
        <act:PrimaryAction>$action_id</act:PrimaryAction>
      </act:NewActionRule>
    </act:AddActionRule>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

echo
echo "Done!"
