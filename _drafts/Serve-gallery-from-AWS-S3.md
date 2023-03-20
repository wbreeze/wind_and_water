---
layout: post
title: Serve gallery from AWS S3
date: 2022-12-06
lang: en
categories:
excerpt:
link_note: "[text for internal link]({{ '/2021/08/four_enemies.html' | relative_url }})"
image_note: "![description]({{ '/assets/images/image.jpeg' | relative_url }})"
---


There is an [AWS Serverless Application Repository][sar] that serves a gallery
without generating any static files. The AWS Lambda function runs on the
request to return an image or index based on the path. It's published
on Github as [evanchiu/serverless-galleria][evan]. The application does not
work with directories. It has the basics.

I'm working with [Creating an application with continuous delivery in the
Lambda console][lap]. There are eight moving parts arranged together. I'm going
to learn how to use CloudFormation. That is something Docker-like, I think.

They want me to use their flavor of git repository, [CodeCommit][cc]. I'm
following instructions for adding credentials to the IAM account I'm using for
development: [Setup for HTTPS users using Git credentials][gitcred].
There's one more user name and password to put in the safe.

[cc]: https://docs.aws.amazon.com/codecommit/index.html
[gitcred]: https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-gc.html
[lap]: https://docs.aws.amazon.com/lambda/latest/dg/applications-tutorial.html
[sar]: https://aws.amazon.com/es/serverless/serverlessrepo/
[evan]: https://github.com/evanchiu/serverless-galleria
