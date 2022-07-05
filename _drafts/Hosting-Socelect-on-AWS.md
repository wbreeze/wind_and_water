---
layout: post
title: Hosting Socelect on AWS
date: 2022-07-05
lang: en
categories:
excerpt:
link_note: "[text for internal link]({{ '/2021/08/four_enemies.html' | relative_url }})"
image_note: "![image description]({{ '/assets/images/image.jpeg' | relative_url }})"
---

[Socelect.org][sc] is a site for running preference surveys using ranked choice.
It is built using [Ruby on Rails][ror].

I've been hosting [Socelect][sc] on a Linux server at [Linnode][ln]. This is
troublesome, because I have to maintain the server. Instead of doing that, I've
decided to move the site to AWS [Amplify][amp]. [Amplify][amp] will build the
site from its [source code repository][scsrc] and serve it for me in a
scalable fashion, just in case it ever becomes wildly popular.

Mostly, it simply won't experience the days of down time I've had while running
it on my own server.

[sc]: https://socelect.org/
[ror]: http://rubyonrails.org/
[ln]: https://www.linode.com/
[scsrc]: https://github.com/wbreeze/socelect
