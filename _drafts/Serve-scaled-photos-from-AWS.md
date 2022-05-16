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

## The Bucket
I started by [creating an S3 bucket][new-bucket] for the photographs.

[AWS]: https://aws.amazon.com/
[S3]: https://aws.amazon.com/s3/
[edge]: https://aws.amazon.com/cloudfront/
[lambda]: https://aws.amazon.com/lambda/
[new-bucket]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html
