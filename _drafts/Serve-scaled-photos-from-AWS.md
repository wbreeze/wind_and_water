---
layout: post
title: Serve scaled photos from AWS
date: 2022-05-16
lang: en
categories: AWS web
excerpt: How to serve images from the Amazon Web Services (AWS) Simple Storage
  Service (S3) via AWS CloudFront edge servers, scaled on the fly,
  with a cache, using AWS Lambda.
link_note: "[internal link]({% link _posts/2019-07-30-socelect.md %})"
image_note: "![image]({% link /assets/images/image.jpg %})"
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

    {
        "CallerReference": "de9dcc8d405e952378421b7bd16b6fbf",
        "Aliases": {
            "Quantity": 3,
            "Items": [
              "media.wbreeze.com", "media.brisa.uy", "media.stormn69.org"
            ]
        },
        "DefaultRootObject": "index.html",
        "Origins": {
            "Quantity": 1,
            "Items": [
                {
                    "Id": "photo-cache-bucket",
                    "DomainName": "photo-da83944a8eb53c3a61a287150146a922.s3.eu-west-1.amazonaws.com",
                    "OriginPath": "/",
                    "CustomHeaders": {
                        "Quantity": 0
                    },
                    "S3OriginConfig": {
                        "OriginAccessIdentity": "origin-access-identity/cloudfront/AE45EXAMPLEOAD"
                    }
                }
            ]
        },
        "OriginGroups": {
            "Quantity": 0
        },
        "DefaultCacheBehavior": {
            "TargetOriginId": "arn:aws:s3:::photo-da83944a8eb53c3a61a287150146a922",
            "ForwardedValues": {
                "QueryString": false,
                "Cookies": {
                    "Forward": "none"
                },
                "Headers": {
                    "Quantity": 0
                },
                "QueryStringCacheKeys": {
                    "Quantity": 0
                }
            },
            "TrustedSigners": {
                "Enabled": false,
                "Quantity": 0
            },
            "ViewerProtocolPolicy": "https-only",
            "AllowedMethods": {
                "Quantity": 2,
                "Items": [
                    "HEAD",
                    "GET"
                ],
                "CachedMethods": {
                    "Quantity": 2,
                    "Items": [
                        "HEAD",
                        "GET"
                    ]
                }
            },
            "SmoothStreaming": false,
            "MinTTL": 0,
            "DefaultTTL": 86400,
            "MaxTTL": 31536000,
            "Compress": false,
            "LambdaFunctionAssociations": {
                "Quantity": 0
            },
            "FieldLevelEncryptionId": ""
        },
        "CacheBehaviors": {
            "Quantity": 0
        },
        "CustomErrorResponses": {
            "Quantity": 0
        },
        "Comment": "Media caching for wbreeze.com, brisa.uy, stormn69.org",
        "Logging": {
            "Enabled": false,
            "IncludeCookies": false,
            "Bucket": "",
            "Prefix": ""
        },
        "PriceClass": "PriceClass_All",
        "Enabled": true,
        "ViewerCertificate": {
            "CloudFrontDefaultCertificate": true,
            "MinimumProtocolVersion": "TLSv1",
            "CertificateSource": "cloudfront"
        },
        "Restrictions": {
            "GeoRestriction": {
                "RestrictionType": "none",
                "Quantity": 0
            }
        },
        "WebACLId": "",
        "HttpVersion": "http2",
        "IsIPV6Enabled": true
    }

The create-distribution attempt would not work for me.
It did not find the origin. Messing with the domain name did not help.

    $ aws cloudfront create-distribution \
    --distribution-config file://distribution.json

    An error occurred (NoSuchOrigin) when calling the CreateDistribution
    operation: One or more of your origins or origin groups do not exist.

In the end I did it manually via the console. The command,
`wget https://abcdef0123456.cloudfront.net/Further.jpg` where
`abcdef0123456.cloudfront.net` is the CloudFront distribution link
given in the console.





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
