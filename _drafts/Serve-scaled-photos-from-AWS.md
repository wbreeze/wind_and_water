---
layout: post
title: Serve scaled photos from AWS
date: 2022-05-16
lang: en
categories: AWS web
excerpt: How to serve images from the Amazon Web Services (AWS) Simple Storage
  Service (S3) via AWS CloudFront edge servers, scaled on the fly,
  with a cache, using AWS Lambda.
---

Here are instructions about how to serve images from the
[Amazon Web Services (AWS)][AWS] [Simple Storage Service (S3)][S3]
via [AWS CloudFront edge servers][edge],
scaled on the fly, with a cache, using [AWS Lambda][lambda].

To be crude, it's a royal pain in the ass. It's valuable because it enables
delivery of images for my web sites scaled to sizes suitable for the
pages on which and devices for which they are called for.

By this method, images load rapidly and without excess use of bandwidth. All I
have to do is place the full size images in a bucket. Queries for the scaled
versions take care to retrieve the appropriate sizes.

It's difficult to set-up because it involves configuration of the three
services with appropriate permissions and etc. Somehow you get it just right
and it works. My hope is that this:

- helps to document how I've done it
- helps you do it for yourself

I've used the AWS command line interface (awscli) and included the commands
used in order to facilitate reproducing this work.

### IAM administrator
I did all of this setup using [IAM administrator credentials][admin] configured
for my account through the IAM console. I used the [aws configure][config]
command to store these credentials with the aws command line interface.

## The AWS region

It's necessary to choose a region in which to keep the files and execute the
Lambda programs. The Lambda programs will incur extra charges if you ask them
to read and write files in a region different than that in which they are
running.

The [AWS Regional Services List][rservices] has a list of services supported
in each region. Ensure that S3, Lambda and CloudFront are all supported in
the region that you would like to use. Lambda is listed as "AWS Lambda".
S3 and CloudFront are listed with the prefix "Amazon".

I haven't found a command line method to list regions, however Amazon publishes
a map on their [global infrastructure site][infra]. The region descriptors used
by the CLI are not there, though. The only place I've found a list of them
is in the region selector drop-down of the AWS console.

Some example region descriptors are:

- *us-east-1*, that is United States East, Northern Virginia
- *eu-west-1*, that is Western Europe, Ireland
- *sa-east-1*, that is South America, Sao Paulo

## The Photo Bucket

I started by [creating an S3 bucket][new-bucket] for the photographs.
AWS S3 Bucket names must be unique to the region.
An md5 checksum serves to generate something random enough.
I prefixed the name with "photo-" to help me identify this bucket among the
list of buckets that I'm managing on S3.

The commands to use are the `s3api` [create-bucket][create-bucket]
and [put-public-access-block][ppab] commands.

    $ echo 'this is a hash of a string' | md5sum -t -s
    da83944a8eb53c3a61a287150146a922  -
    $ aws s3api create-bucket \
    --bucket photo-da83944a8eb53c3a61a287150146a922 \
    --region eu-west-1 \
    --create-bucket-configuration LocationConstraint=eu-west-1 \
    --object-ownership BucketOwnerEnforced
    {
        "Location": "/photo-da83944a8eb53c3a61a287150146a922"
    }
    $ aws s3api put-public-access-block \
    --bucket photo-da83944a8eb53c3a61a287150146a922 \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true, \
    BlockPublicPolicy=true,RestrictPublicBuckets=true"

In order to place the bucket in a regon other than *us-east-1* it was necessary
to specify the region in two places, using the `--region` and
`--create-bucket-configuration` options to `create-bucket`.

The next interesting thing to do is to upload an image to the bucket.
To begin with, I'll upload to the root directory of the bucket.
The command to use is the `s3api` [put-object][put-object] command.

    $ aws s3api put-object \
    --bucket photo-da83944a8eb53c3a61a287150146a922 \
    --key Further.jpg \
    --body assets/images/Further.jpg
    {
        "ETag": "\"52d9a45747e63835d1533f4f6ba82945\""
    }

The `key` is the path on the bucket. The `body` is the local file.
Looking at the bucket in the AWS console, there is the image.

Next I'll set-up a method to retrieve the image with a web browser.

## CloudFront

[CloudFront (CF)][edge] is the edge delivery service of AWS. It routes requests
to nearby servers strategically located around the world in order to deliver
content with minimum delays.

### Origin Access ID (OAI)

The first task is to establish an identity that CF can use to access files
in the S3 photo bucket. The AWS documentation calls this an [origin access
identity (OAI)][oai]. We're following instructions in the AWS developer guide
titled, "[Restricting access to Amazon S3 content by using an origin access
identity (OAI)][oaids3]".

    $ echo 'origin identity for photo bucket photo-da83944a8eb53c3a61a287150146a922' | md5sum -t -s
    a915fccb5fb20664ba4237c326f46a33 -
    $ aws cloudfront create-cloud-front-origin-access-identity \
        --cloud-front-origin-access-identity-config \
            CallerReference="a915fccb5fb20664ba4237c326f46a33",Comment="Photo Bucket photo-da83944a8eb53c3a61a287150146a922"
    {
        "Location": "https://cloudfront.amazonaws.com/2020-05-31/origin-access-identity/cloudfront/ABCDEFGHOIDEXP",
        "ETag": "ABCDEFGETAGEXP",
        "CloudFrontOriginAccessIdentity": {
            "Id": "ABCDEFGHOIDEXP",
            "S3CanonicalUserId": "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
            "CloudFrontOriginAccessIdentityConfig": {
                "CallerReference": "refhabcdef0123456789abcdef012345",
                "Comment": "Photo Bucket photo-da83944a8eb53c3a61a287150146a922"
            }
        }
    }

The `CallerReference` parameter has to be unique within
my account. I used `md5sum` to generate something. For the comment, I put the
name of the photo bucket. The output contains an Id and S3CanonicalUserId.
These I stored in my password database along with the complete location.
They are needed secrets.

Having established an origin ID (OAI) it is necessary to register it with the
S3 Bucket. The following is from the [CloudFront Developer Guide][oaids3b].

    {
        "Version": "2012-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ABCDEFGHOIDEXP"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::photo-da83944a8eb53c3a61a287150146a922/*"
            }
        ]
    }

The [awscli s3api put-bucket-policy][put-bucket-policy] command will write
the policy to the photo bucket. Then the CloudFront distribution will be
able to read from the bucket. Note the policy is read only. We go with the
minimum access required.

    $ aws s3api put-bucket-policy \
    --bucket photo-photo-da83944a8eb53c3a61a287150146a922 \
    --policy file://s3policy.json

### CloudFront Distribution

Now we can create a CF distribution using the OAI.
We use the [aws cloudfront create-distribution][cfcreated] command.

I put the distribution configuration in a text file, starting with the
skeleton generated by:

    aws cloudfront create-distribution \
    --generate-cli-skeleton >distribution2.json \
    >distribution.json

The file, `distribution.json` is too long to reproduce here.  You can view or
download it as [distribution.json][distjson] following that link.

The create-distribution attempt would not work for me.
It did not find the origin. Messing with the domain name did not help.

    $ aws cloudfront create-distribution \
    --distribution-config file://distribution.json

    An error occurred (NoSuchOrigin) when calling the CreateDistribution
    operation: One or more of your origins or origin groups do not exist.

In the end I did it manually via the console. As a test, the command,
`wget https://abcdef0123456.cloudfront.net/Further.jpg` retrieves the image.
The server `abcdef0123456.cloudfront.net` is the CloudFront distribution link
given in the console.

## Lambda Functions

With the CloudFront service going strong, it's time to add a pair of Lambda
functions that will dynamically scale and cache scaled images based upon
query parameters sent from the browser, from the page retrieving the images.
The strategy for doing this and some guidance come from a 2018 CDN Blog
post, "[Resizing Images with Amazon CloudFront & Lamda@Edge][rsiacl]".

I decided to make some adjustments to the functions outlined in that post,
and did so in an open source project on GitHub, [wbreeze/awsLambdaImage][awsl].

### Building and Packaging

The functions are written with JavaScript that executes in a Node.js
execution environment. In order to deploy them to AWS Lambda I follow the
instructions given in the AWS docs,
"[Deploy Node.js Lambda functions with .zip file archives][depl]".
The functions depend on the Node.js sharp module. The installation for
the sharp module compiles native code. This means the packages must be
built in a machine that duplicates the Lambda runtime environment.

To package the code, I start an AWS EC2 instance running Amazon Linux in the
console and then shell to it.

    ssh -i "~/.ssh/AWSEC2.pem" ec2-user@ec2-id.eu-west-1.compute.amazonaws.com

The [project][awsl] has scripts for setting-up the machine, cloning and
initializing the awsLambdaImage project, building, and distributing the
Lambda function. Instructions are in the project README.md file.

To make things easier for myself, I copy the zip files to my local machine:

    scp -i "~/.ssh/AWSEC2.pem" \
      ec2-user@ec2-id.eu-west-1.compute.amazonaws.com:~/awsLambdaImage/resize.zip .
    scp -i "~/.ssh/AWSEC2.pem" \
      ec2-user@ec2-id.eu-west-1.compute.amazonaws.com:~/awsLambdaImage/request.zip .

### Creating a Role

In order to access the S3 bucket, or to do anything useful really, the Lambda
functions must have a role associated. This will be the role to which we
grant read, write, or read and write access to the Lambda functions. To do
this, I followed the instructions for [Creating a role for a service][role]
using the [create_role api command][crol].

    $ aws iam create-role \
    --role-name "lambda-scaling-access-photo-buckets" \
    --assume-role-policy-document file://role_policy.json \
    --description "Lambda scaling function access to S3 image buckets"

The content of the `role-policy.json` file is

      "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Effect": "Allow",
                  "Principal": {
                      "Service": "edgelambda.amazonaws.com"
                  },
                  "Action": "sts:AssumeRole"
              },
              {
                  "Effect": "Allow",
                  "Principal": {
                      "Service": "lambda.amazonaws.com"
                  },
                  "Action": "sts:AssumeRole"
              }
          ]
      }

The output contains a RoleId and an Arn for the role. The AWS account Id
forms part of the Arn together with the name of the role. For example,

      "RoleId": "AROAROLEDFORLAMBDA54E",
      "Arn": "arn:aws:iam::012345678901:role/lambda-scaling-access-photo-buckets",

### Creating the Functions in Lambda

Now I'm ready to create the functions, I think. I have both the distribution
packages and the role needed to create them. I use the AWS Lambda
[`create-function`][cfun] command as follows:

    $ aws lambda create-function \
    --function-name scale_image \
    --runtime nodejs16.x \
    --description "scale images on the fly" \
    --handler index.handler \
    --package-type Zip \
    --zip-file fileb://resize.zip \
    --publish \
    --role "arn:aws:iam::012345678901:role/lambda-scaling-access-photo-buckets" \
    --region us-east-1

The command to create the URL rewriting function, `request.js` differs only
in the function-name, description, and zip-file name. I give it the role
although I'm not sure it is needed.

The return includes an AWS Arn for the function that is useful for updating
the function code. The relevant tag is `FunctionArn`. The Arn includes the
region, account Id, and name of the function, for example
`arn:aws:lambda:us-east-1:012345678901:function:scale_image`.

### S3 Bucket Access

The S3 bucket that contains the image files must grant permissions to the
image scaling Lambda function for reading and writing. It does so by
identifying the Lambda function role in its access policy.

I use the AWS [`put-bucket-policy` command][put-bucket-policy] with a new
version of the policy file. The new policy file has additional entries in
the policy statement as follows

    {
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::012345678901:role/lambda-scaling-access-photo-buckets"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::photo-da83944a8eb53c3a61a287150146a922/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::012345678901:role/lambda-scaling-access-photo-buckets"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::photo-da83944a8eb53c3a61a287150146a922/*"
    }

You can view the complete policy as [`s3policy2.json`][policyjson].

    $ aws s3api put-bucket-policy \
    --bucket photo-photo-da83944a8eb53c3a61a287150146a922 \
    --policy file://s3policy2.json

## Configure CloudFront with Lambda functions

We install the `request` Lambda function as a callback for the CloudFront
Viewer Request event. It rewrites the image URL according to the scaling
query parameter, to identify the scaled image file.

We install the `resize` Lambda function as a callback for the CloudFront
Origin Response event. It creates the scaled image if it did not already
exist in the S3 scaled image bucket.

According to the CloudFront [`update-distribution` AWS CLI command
reference][upd-dist] we proceed by first pulling the existing distribution
configuration, modifying it, and then posting the new one. The function might
better be called "replace-distribution", but good enough.

    $ aws cloudfront get-distribution-config \
    --id ABCDEFGHOIDEXP >distrib.json

The returned json data includes everything. I'm interested in updating the
callback function settings. The response contains an ETag element that we
delete, however, we must retain the value for use in the `update-distribution`
command. The ETag looks something like this, `E2QETAGEXAMPLE`.

In addition to removing the ETag, I update the `FunctionAssociations` element
as follows:

    "LambdaFunctionAssociations": {
        "Quantity": 2,
        "Items": [
          {
              "LambdaFunctionARN": "arn:aws:lambda:us-east-1:012345678901:function:rewrite_request_url:1",
              "EventType": "viewer-request",
              "IncludeBody": false
          },
          {
              "LambdaFunctionARN": "arn:aws:lambda:us-east-1:012345678901:function:scale_image:1",
              "EventType": "origin-response",
              "IncludeBody": false
          }
        ]
    },

and then provide it to the `update-distribution` command as follows:

    $ aws cloudfront update-distribution \
    --id ABCDEFGHOIDEXP \
    --if-match E2QETAGEXAMPLE \
    --distribution-config file://distrib.json

Houston, there's a problem. The call returns an error, "The function must be in
region 'us-east-1'". Nice. The Lambda docs tell us to put the functions in the
same region as any S3 buckets they access. This is telling us that the function
has to be in region us-east-1. What to do?

One solution would be to capitulate, and put everything in region us-east-1.
Well, let's see if there's something else we can do.

It seems clear from the [Developer Guide Restrictions on Lambda@Edge][ledger]
that the function has to reside in region `us-east-1`. For the moment, I'll
put it there and not worry about the cross-region access to the S3 bucket
in region `eu-west-1`. Will revisit that later.

## Debugging

As expected, the functions do not work. Retrieving a scaled image with curl
retrieves the full sized image,
`curl --get --output Further.jpg "https://abcd0123.cloudfront.net/Further.jpg?d=600"`

The Lambda functions need additional permissions to write to CloudWatch logs.
The monitor tab of the console says, "add the AWSLambdaBasicExecutionRole
managed policy to its execution role"

The execution role is `lambda-scaling-access-photo-buckets`, the role given
read and write permissions within the S3 bucket. How do I add a managed policy
to a role?

Browsing the AWS IAM command line documentation I see a command,
[`attach-role-policy`][arp]. The description looks promising,
"Attaches the specified managed policy to the specified IAM role." So good.

The command needs the arn for the managed policy. I found it by searching
the name of the policy in the AWS console, [AWSLamdbaBasicExecutionRole][alber].

    $ aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
    --role-name lambda-scaling-access-photo-buckets

and sure enough, it shows up as a "Permissions policies" in the Permissions
tab for the role in the IAM console. Voila. Reloading the Monitor tab in the
console view of the Lambda function, the advisory message no longer appears.
Perhaps now the functions are enabled for logging. Do I have to do anything
more to update them with the CloudFront distribution? I'm guessing not.
It will just work.

Checking the Logs page of the CloudFront AWS console, I see that logging is
not enabled-- not standard nor real-time. Enabling it from the command line
requires the same configuration replacement gymnastics that I did (above) to
install the function callbacks. Maybe it will be easier simply to enable them
in the console.

Well, not so. The log requires an S3 bucket. I tried giving it the photo bucket
and got an error, "Failed to update distribution details: The S3 bucket that
you specified for CloudFront logs does not enable ACL access"
Bock to the developer guide, ["Choosing an Amazon S3 bucket for your standard
logs][logbucket].

It pretty much says to create a bucket with ACLs enabled. This is something
that the S3 documentation deprecates. So be it.

    $ aws s3api create-bucket \
    --bucket cloudfront-logs-da83944a8eb53c3a61a287150146a922 \
    --region us-east-1 \
    --create-bucket-configuration LocationConstraint=eu-west-1 \
    --object-ownership BucketOwnerPreferred

Hitting the edge server with an image request causes, eventually, a log to
appear in the log bucket. Good start. (Getting real time logs requires setting
up something called "Kinesis", so; I'm passing on that.)

After adding logging statements to the request.js code in the awsLambdaImage
project and running the tests, I have to push the code to the git repository,
shell to the EC2 instance, build, and then update the function for Lambda
and CloudFront.

### Update Lambda function

With a new distribution zip file, `request.zip` I use the [AWS Lambda `update-function-code`][updfn] command as follows:

    $ aws lambda update-function-code \
    --function-name "rewrite_request_url" \
    --zip-file fileb://request.zip \
    --publish \
    --region us-east-1

This generates a new version for the function. I have to tell CloudFront to
use the new version. The AWS CLI CloudFront `update-function` command doesn't
look like the ticket. This looks like some other kind of function. What's
needed is the whole distribution replacement workflow. Maybe it's easier to
do it in the console. Yes. I have to edit the behavior for the distribution
to change the function ARN.

After that, I send another curl request to retrieve a scaled image. After
waiting several minutes, the new log file appears in the bucket.
The log doesn't contain anyting from the console logging commands. It's
essentially the same as before.

Pah. Okay. Here's the scoop on
[logging statements from Lambda Node.js functions][logjs]
and [viewing the logs][logcons] from the AWS console.
The first reference includes instructions for invoking the function and
retrieving the log from the AWS CLI (command line).
However following those instructions yields an error, "The specific log group:
/aws/lambda/rewrite_request_url does not exist in this account or region."

I think there's an enablement that I haven't provided. Let's see. More digging.
It looks like it ought to be working. Now follow this operator guide for
AWS Lambda [Monitoring and observability][lambmon]. This tells me that it ought
to be working automagically. Perhaps I haven't made enough invocations to
generate the log?

I'm getting the feeling the function is never invoked. There's this "Deploy
to Lambda@Edge" action that I haven't done and that doesn't work. It says
that the runtime environment must be Node.js 12.x or 14.x. What have I installed
on the EC2 instance? 16.15. So that needs to be 14.x. At the command line
of the EC2 instance,

    $ nvm install 14
    Downloading and installing node v14.19.3...
    Downloading https://nodejs.org/dist/v14.19.3/node-v14.19.3-linux-x64.tar.xz...
    ################################################################################### 100.0%
    Computing checksum with sha256sum
    Checksums matched!
    manpath: can't set the locale; make sure $LC_* and $LANG are correct
    Now using node v14.19.3 (npm v6.14.17)

And then do the whole build, download, upload, update version workflow.
I'm thinking to configure the AWS CLI on the EC2 instance because downloading
and then uploading the zip files takes a while. They are only 18MB but my
internet is slow here.

I also use the console to edit the runtime configuration. Changing it to Node.js
14.x I get a message about the new runtime 16.x available. Ignoring that.

I'm still not getting a log group nor any log streams for `/aws/lambda/rewrite_request_url`. Try creating the log group in the console and running the curl command
again.

What's happening is that the image loads from the edge server, without any
scaling, without invoking either of the functions. The configuration indicates
that the functions ought to be invoked on the Viewer request and Origin response
callbacks. The Function ARNs and versions are correct. I'm stumped for the
moment.



[oai]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[AWS]: https://aws.amazon.com/
[S3]: https://aws.amazon.com/s3/
[edge]: https://aws.amazon.com/cloudfront/
[lambda]: https://aws.amazon.com/lambda/
[new-bucket]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html
[rservices]: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/
[infra]: https://aws.amazon.com/about-aws/global-infrastructure/
[put-object]: https://docs.aws.amazon.com/cli/latest/reference/s3api/put-object.html
[create-bucket]: https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html
[ppab]: https://docs.aws.amazon.com/cli/latest/reference/s3api/put-public-access-block.html
[config]: https://docs.aws.amazon.com/cli/latest/reference/configure/index.html
[admin]: https://aws.amazon.com/getting-started/guides/setup-environment/module-two/
[oaids3]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html#private-content-creating-oai
[oaids3b]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html#private-content-granting-permissions-to-oai
[cfcreated]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudfront/create-distribution.html
[put-bucket-policy]: https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html
[distjson]: {{ 'assets/files/distribution.json' | relative_url }}
[rsiacl]: https://aws.amazon.com/blogs/networking-and-content-delivery/resizing-images-with-amazon-cloudfront-lambdaedge-aws-cdn-blog/
[awsl]: https://github.com/wbreeze/awsLambdaImage
[depl]: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-package.html
[role]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html
[crol]: https://docs.aws.amazon.com/cli/latest/reference/iam/create-role.html
[cfun]: https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html
[policyjson]: {{ 'assets/files/s3policy2.json' | relative_url }}
[upd-dist]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudfront/update-distribution.html
[ledger]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html#lambda-at-edge-function-restrictions
[alber]: https://us-east-1.console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole$serviceLevelSummary
[arp]: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/attach-role-policy.html
[logbucket]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#access-logs-choosing-s3-bucket
[updfn]: https://docs.aws.amazon.com/cli/latest/reference/lambda/update-function-code.html
[logjs]: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-logging.html
[logcons]: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
[lambmon]: https://docs.aws.amazon.com/lambda/latest/operatorguide/monitoring-observability.html
