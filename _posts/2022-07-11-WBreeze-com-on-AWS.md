---
layout: post
title: WBreeze.com on AWS
date: 2022-07-11
lang: en
categories: WBreeze.com tech AWS sites
---

I've been serving [WBreeze.com][wb] from a Linux server hosted at Linode. The
trouble with doing so is that I have to maintain the server and software
installations. This is one too many chores for me; so, instead I've chosen the
chore of moving the site to AWS.

![WBreeze.com home page](
  {{ '/assets/images/2022/wbc/home.png' | relative_url }}
)

[WBreeze.com][wb] is a static web site. All of the resources-- pages,
stylesheets, images --are served from files. In other words, there are no
programs to run on the server other than the program that delivers files
requested from web browsers.

[Amazon Web Services][aws] offers a couple of solutions for hosting static web
sites such as [WBreeze.com][wb]. One of them is the [AWS Amplify][amp] service
that automates storage and synchronization, and serves the files to browsers.
The other is to place the files on [Simple Storage Service S3][s3] and serve
them using [CloudFront][cf]. AWS has published an article about how to do
that,
"[How do I use CloudFront to serve a static website hosted on Amazon S3?][host]".

I'm going to investigate both.

## S3 Bucket

The first step is to set up an S3 bucket and populate it with the files.
I'd like some scripts to take care of populating the files. I can run these
scripts when the content changes, in order to refresh it.

I created the bucket using the S3 console:
- naming it "wbreeze.com-{random letters and numbers}"
- with no versioning
- with no encryption
- no logging
- no Access Control Lists (ACLs)
- no object locking
- no public access

We'll call the bucket, "wbreeze.com-bucket" in order to give it a name.
Amazon has a name for it that we aren't using here.

Looking at the bucket properties, here is a configuration for "[Static website
hosting][s3h]" with the referenced link for more information.
Reading the referenced link I see that this will not support secure encrypted
requests from browsers (using the `https:` protocol).
For this reason, I don't find it to be appropriate. Unsecured websites are
frowned upon these days, and for good reason. All of the traffic to them is
wide open for anyone or anything to read, and they're easier to hijack.

## Amplify

![WBreeze.com aviation page](
  {{ '/assets/images/2022/wbc/aviation.png' | relative_url }}
)

Amplify offers a service that serves static web pages backed by a source
control system. You specify the source repository and branch. Amplify pulls
changes to that branch and serves-up the files.

[WBreeze.com][wb] is heavy on images, as in, there are a lot of pictures.
Source control systems aren't great for binary data. It isn't exactly what
they're designed for. They do it, and don't do a bad job of it, but it isn't
close to their best function, that is, to track changes in text files.

For that reason, I do have the site under source control, but do not have
the images under source control. I keep the images backed-up in an [AWS S3][s3]
bucket, copied to the site server and refreshed using `scp`.
That the entire site, wholly grown, can't be pulled from the source code
repository creates a problem for Amplify. My solution will be to maintain the
site wholly grown in an S3 bucket using scripts, and have Amplify serve from
the S3 bucket.

The documentation for this is indexed under what AWS calls, "Manual deploys".
I followed instructions from the section,
"[To manually deploy an app from Amazon S3][manual]."

Starting from the Amplify console I selected "New app". This started a
dialog in which I elected:
- to deploy without a git provider
- to manually deploy from an Amazon S3 Bucket
- specified the S3 bucket I created for the site, `wbreeze.com-bucket`.

When deploying, I got an error, "An error occurred during the publish
operation: Deployment file has not been uploaded". Using that in a web search I
discovered [a closed issue on GitHub][2266] where people indicate that the
deploy is successful in spite of the error report. However it does not.

Perhaps the trouble is that Amplify is looking for a build specification. The
build specification is a file called `amplify.yml` in their [documented YAML
syntax][ampyml]. I put [this `amplify.yml` file][myampyml] in the
wbreeze.com-bucket.

Perhaps the bucket, at minimum, has to have an `index.html` file.
I've created an [index.html][index] file for this purpose, following
the basic anatomy of an [HTML file][anat].

Neither of these actions helped. Perhaps it is that Amplify cannot access
the bucket. I tried placing a policy on the bucket that gives access to
the `amplify.amazonaws.com` service. This didn't do the job, either.

Perhaps later I'll understand how to grant Amplify access to the S3 bucket.
The feeling I'm getting is that it will want to copy resources from there
in order to "build" the web site.

Actually, with Amplify, I've had success, in the past, giving it access to the
source repository and providing a build script. The issue was providing the
images. That would require copying them from somewhere or putting them in the
repository.  For that reason I got sidetracked on providing an S3 bucket with
the images served from CloudFront.

Serving the images from an S3 bucket via CloudFront, I may as well serve
the site that way. So here we are. Let's try setting-up CloudFront to
serve the files from the bucket.

## CloudFront

I set-up CloudFront from the AWS console using the new distribution button.
For the settings, I chose:
- The S3 bucket with the files for WBreeze
- empty origin path
- name, "Serve WBreeze.com"
- creating an Origin Access Identity (OAI) for the distribution
- updating the policy of the S3 bucket to allow the OAI
- no custom headers
- no origin shield
- defaults for the cache behavior
- redirect HTTP to HTTPS
- GET and HEAD requests only
- no signed url's
- no function associations
- North America and Europe because the content is not so much of interest
  elsewhere
- I'll do the CNAME and SSL certificates later
- Default root object is 'index.html' This is important. Otherwise the root
  request returns an XML encoded list of files.
- No longing
- IPv6 enabled

With this, I was able to direct my web browser to the distribution domain,
`lettersanddigits@cloudfront.net`. It served the `index.html` file I had
placed in the S3 bucket. Well, that was easy.

### Copy the site

What remains is to populate the S3 bucket with the site content. I wrote a
script to run on the current server, that [copies the web related files][cp2s3]
to the S3 bucket. After doing that I relented. There was too much of a chance
to miss a file extension or referenced file. For example, I'd missed some
`.pdf` and `.txt` files by not including those extensions. The `.xml` files
aren't so huge; they're just text that I typed. I deleted the '.DS_Store' files
and then used `aws s3 sync` to copy everything from the www directory to the S3
bucket.

In the CloudFront console for the distribution I went to the "Error pages"
tab and caused four of the http errors to serve-up specific error pages that
I had constructed for the site.

### Set-up the domain to serve from CloudFront

After doing some sanity checking-- just semi-random poking around on the
CloudFront hosted site to see that everything is working --I'm ready to
request a certificate from AWS and direct the [WBreeze.com][wb] domain to
it.

I'm not going to go into details here. It was pretty straightforward.  The
CloudFront console had a link to the AWS certificate manager where I requested
the certificate.  I had to add a CNAME record to the domain in order to prove
that it is mine.  After the certificate was approved I set it on the CloudFront
distribution along with the domain name in the console.

I have to say, this was so much more straightforward than setting-up
and managing the [Let's Encrypt certbot][cert] on my own server.
AWS will maintain the certificate as current indefinitely, so long as
I'm using it.

The last step was to have the Domain Name Service (DNS) direct
[WBreeze.com][wb] to the CloudFront distribution.  This was the hardest part.
The Amazon Route 53 documentation has an article about moving to Route 53,
"[Making Route 53 the DNS service for a domain that's in use][route]".  The
trouble with the article is that it imagines copying the DNS records from the
existing DNS server to Route53. With their import of a zone file (impossible to
get) or even manually, I wasn't able to do that (as of this writing).

What worked was to delete the `A` records for the root domain (`wbreeze.com`)
and create a `CNAME` record that directs `wbreeze.com` to
`lettersanddigits@cloudfront.net`. It isn't possible to create the `CNAME`
record before deleting the `A` record; so, there was a fragment of possible
downtime.

## Conclusion

![WBreeze.com gallery page](
  {{ '/assets/images/2022/wbc/gallery.png' | relative_url }}
)

This isn't ideal, but rather expedient. Better would be to enable [Amplify][amp]
to build the site from the source repository. I've had that working once
in the past. The barrier is the images. If I'm going to host the site with
[Amplify][amp], I'll have to put the images somewhere.

The source repository isn't a great place for all of the images. There is
[Git Large File Storage][lfs], but that isn't exactly what I'm after.
It simply doesn't make sense to have all of these images under source control.

Another project is to make an images bucket that has all of my images-- years
and years of photos --backed by a dynamically produced gallery. In that way,
all I have to do to update the gallery is to add images to the S3 bucket.
Simply by managing the files, I'll have an up to date gallery.

In addition, that image bucket would be the image source for my web sites,
like [WBreeze.com][wb], [StormN69.org][s69], and the [Wind and Water][wnw]
blog.

[WBreeze.com][wb] and [StormN69.org][s69] are produced with XML markup and XSL
stylesheets. That was really cool twenty years ago.  More recently I've been
writing sites with [Markdown][md] and serving them up using the
[Jekyll][jekyll] Ruby based static site transformer and server. Two of the
sites I've set-up using [Jekyll][jekyll] are [Brisa.uy][brisa] and the [Wind
and Water][wnw] blog.

Another chore would be to convert [StormN69.org][s69] and [WBreeze.com][wb] to
[Markdown][md], using a transform, and carry-on updating them as
[Jekyll][jekyll] sites. That is, to make a technology change, to migrate the
sites to a new platform.

For now, I've gotten [WBreeze.com][wb] onto AWS where I don't have to worry
about maintaining a server nor experience days of downtime.

[brisa]: https://brisa.uy/
[jekyll]: https://jekyllrb.com/
[md]: https://daringfireball.net/projects/markdown/
[s69]: https://stormn69.org/
[wnw]: https://wnw.wbreeze.com/
[s3]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
[cf]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
[amp]: https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html
[host]: https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-serve-static-website/
[aws]: https://aws.amazon.com/
[wb]: https://wbreeze.com/
[s3h]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
[anat]: https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/HTML_basics#anatomy_of_an_html_document
[index]: {{ '/assets/files/2022/index.html.xml' | relative_url }}
[manual]: https://docs.aws.amazon.com/amplify/latest/userguide/manual-deploys.html#amazon-s3-or-any-url
[myampyml]: {{ '/assets/files/2022/amplify.yml.txt' | relative_url }}
[ampyml]: https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html#yml-specification-syntax
[2266]: https://github.com/aws-amplify/amplify-hosting/issues/2266
[lfs]: https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage
[cp2s3]: https://gitlab.com/dclovell/wbreeze.com/-/blob/master/cp2s3.sh
[cert]: https://letsencrypt.org/
[route]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html
