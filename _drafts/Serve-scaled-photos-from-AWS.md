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

## The Bucket

I started by [creating an S3 bucket][new-bucket] for the photographs.
AWS S3 Bucket names must be unique to the region.
An md5 checksum serves to generate something random enough.
I prefixed the name with "photo-" to help me identify this bucket among the
list of buckets that I'm managing on S3.

    $ echo 'this is a hash of a string' | md5sum -t -s
    da83944a8eb53c3a61a287150146a922  -
    $ aws s3api create-bucket \
    --bucket photo-da83944a8eb53c3a61a287150146a922 \
    --region us-east-1 \
    --object-ownership BucketOwnerEnforced
    {
        "Location": "/photo-da83944a8eb53c3a61a287150146a922"
    }
    $ aws s3api put-public-access-block \
    --bucket photo-da83944a8eb53c3a61a287150146a922 \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true, \
    BlockPublicPolicy=true,RestrictPublicBuckets=true"

[AWS]: https://aws.amazon.com/
[S3]: https://aws.amazon.com/s3/
[edge]: https://aws.amazon.com/cloudfront/
[lambda]: https://aws.amazon.com/lambda/
[new-bucket]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html
[rservices]: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/
[infra]: https://aws.amazon.com/about-aws/global-infrastructure/
