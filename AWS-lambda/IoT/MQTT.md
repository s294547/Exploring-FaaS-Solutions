# AWS LAMBDA + AWS IoT Core

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [AWS IoT Core](#aws-iot-core)
3. [Connect an IoT device to AWS IoT Core](#connect-an-iot-device-to-aws-iot-core)
	1. [Creating a thing](#creating-a-thing)
	2. [Attaching a policy](#attaching-a-policy)
4. [Triggering a Lambda using Rules in AWS IoT Core](#triggering-a-lambda-using-rules-in-iot-core)
	1. [Creating the rule](#creating-the-rule)


## Introduction

In this file we will describe the possible alternatives to deliver data from IoT devices to AWS Lambdas. The proposed solution based on the MQTT protocol, using the AWS IoT Core. 

## AWS IoT Core

AWS IoT Core lets you connect billions of IoT devices and route trillions of messages to AWS services without managing infrastructure.

This is the service that the devices directly connect to, for transmitting data. It allows for several communication protocols like MQTT, HTTPS, MQTT over WebSocket, and even LoRaWAN. And the communication is secured with end-to-end encryption and also authentication. Once the data is received by the IoT Core, you can define rules to transfer it forward to other services (like lambda), or take some action based on that data.

[iot-core](./../iot-core.png)
[reference](https://aws.amazon.com/iot-core/?nc=sn&loc=2&dn=3)

## Connect an IoT device to AWS IoT Core

[reference](https://iotespresso.com/how-to-connect-esp32-to-aws-iot-core/)

[aws-iot](./aws-iot.png)

### Creating a Thing
On the AWS Console, click on the ‘Services’ dropdown, and select *IoT Core*.

On the IoT Core homepage, you can refer to the menu on the left side. Over there, click on ‘Manage’, and select ‘Things’. On the page that opens up, click on ‘Create Things’.

A thing is a representation of our physical device on AWS. Once you click on ‘Create things’, you will be asked several questions, in the sequence below:

- Number of things to create – Click on ‘Create single thing’ for now, and click ‘Next’
- Thing name – Give it a suitable name, like *esp32_0*
- Leave out the optional additional configurations
- In the Device Shadow section, select ‘No shadow’ and click ‘Next’. 
- For the Device Certificate section, click on the recommended ‘Auto-generate a new certificate’, and click on ‘Next’
- In the Policies section, do nothing for now (we will create and attach a policy to this thing in the immediate next section).
- Click on ‘Create thing’.

You will be shown a popup for downloading the certificates and private keys. It will look like this:

[aws-iot](./aws_iot3.png)

Out of these, you need to only download the highlighted files:
1. Device Certificate –
2. Private key file
3. Amazon Root CA 1

All these will be required in the Arduino code of ESP32 (if using ESP32).

Once you’ve downloaded the required files, click ‘Done’. Congratulations!! Your thing is created.

### Attaching a Policy
Now that we have a thing and its certificate created, we will attach a policy to the certificate, to limit the scope of actions for that thing. In the left-side menu, click on Secure -> Policies, and click on ‘Create’

In the form that opens up, give the policy a suitable name, like ESP32Policy, and then add the following statements:
- iot:Connect
- iot:Subscribe
- iot:Receive
- iot:Publish

For each statement, AWS will contain some placeholders, starting with ‘replaceWith’, which you need to fill. For instance, in place of ‘replaceWithAClientId’, enter the name of your thing. In place of ‘replaceWithATopicFilter’, add *esp32/sub* for the Subscribe and Receive statements, and *esp32/pub* for the Publish statements.

We essentially give our thing the permission to connect, subscribe to ‘esp32/sub’ topic, receive messages from ‘esp32/sub’ topic, and publish to ‘esp32/pub’ topic.

In the ‘Effect’ section, check ‘Allow’ for each statement. After adding the statements, click on ‘Create’.

Next, within the ‘Secure’ menu on the left, click on Certificates. Click on the certificate of your device, go to ‘Actions’, and click on ‘Attach policy’.

In the popup that opens up, choose the policy you just created, and click on ‘Attach’.

That’s it. The AWS Setup is done.

## Triggering a Lambda using Rules in AWS IoT Core

[reference](https://iotespresso.com/triggering-a-lambda-using-rules-in-aws-iot-core/)

 In the previous section, we made the ESP32 (provided we are using ESP32) send messages to the ‘esp32/pub’ topic on AWS IoT Core. In this section, we will see how to take an action based on the received messages. Just to recap, a sample message sent from ESP32 to the ‘esp32/pub’ topic looks like:

```
{
  "elapsed_time": 52000,
  "value": 566
}
```

In this section, let’s define a rule to trigger a lambda whenever the magnitude of ‘value’ crosses 800.

### Creating the rule

Go to the AWS IoT Core Console, and from the left menu, click on the ‘Act’ dropdown, and click on ‘Rules’. On the screen that opens up, click on ‘Create’.

Give your rule a suitable name and description. Leave the SQL version to the default value, and for the rule query statement, add the following:

```
SELECT * FROM 'esp32/pub' where value>800
```

You can change the topic name and the *WHERE* condition if you are using a different topic.

Note that the SQL query statement is used to filter out messages that should generate a trigger. The above statement, for example, will trigger the action only when the value in an incoming message is above 800.

Next, click on ‘Add action’. Out of the list of actions that opens up, select ‘Send a message to a Lambda function’, and then click on ‘Configure action’. As you can see, there are several other actions possible. You are encouraged to explore them.

You will then need to select the lambda function. You can use any lambda function.

The message sent to the lambda function goes into the ‘event’ argument. You can print the event at the beginning of the function to verify that.

Once you have selected the lambda, click on ‘Add action’. You can set optional ‘Error action’ and optional ‘Tags’. We’ll skip them for now. Click on ‘Create rule’.

Your rule is now created. If you navigate to the lambda function, you should see a trigger from AWS IoT.