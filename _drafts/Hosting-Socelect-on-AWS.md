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
It is built using [Ruby on Rails][ror] (RoR).

I've been hosting [Socelect][sc] on a Linux server at [Linnode][ln]. This is
troublesome, because I have to maintain the server. Instead of doing that, I've
decided to move the site to Amazon Web Services.

With a managed service the site won't experience the days of down time I've had
while running it on my own server.  Hopefully, it won't cost a lot more.

Right now, the server costs $10/mo. For the convenience of not having to
manage the server, keep it up to date, maintain the SSL certificates, etc.--
perhaps I'll pay double, triple at the outside.

## Finding a platform

At first I thought I could use AWS [Amplify][amp]. My thought was that
[Amplify][amp] would build the
site from its [source code repository][scsrc] and serve it for me.
I thought it would be more or less equivalent to setting-up [Travis][travis]
for testing.

Delving into it a bit, I found myself in a rabbit hole of dozens of open
AWS Document tabs. I just couldn't figure-out how to make it work, and
got the idea that perhaps it wasn't the way to go.

Poking around the internet to see what others are doing to deploy RoR, I see
that many use their own servers. Others use [Heroku][hk]. Heroku has a hobby
tier that would give me a 512Mb machine with Postgres database for $16/mo. The
problem is that I found, on Linode, that a 1Gb machine is the minimum. I'm not
exactly sure why. I simply remember needing to upgrade the Linode box from
512Mb to 1Gb. The 1Gb machine on Heroku is $50/mo. plus the database.  That's
ridiculously expensive for this little hobby of mine.

Others use AWS [Elastic Beanstalk][eb] (EB). Calculating cost of EB means
calculating the cost of the services it sets-up-- S3 for storage, [EC2][ec2] for
a server, some sort of database, etc. I'm using the [AWS pricing calculator][awsp]
to try to get a ballpark estimate. It's difficult, because AWS is very fine
grained with pricing of every service. There are many combinations. I feel
a little like I'm guessing.

Choosing [EC2][ec2] with two cpu's, 1Gb memory and 30Gb storage,
plus [MariaDB][rds] with one cpu, 1Gb memory and 5Gb storage
I get a cost of about twenty-five bucks a month. That's a heck of a lot
better than Heroku! It's also smack dab in the middle of my hoped for and
outside cost targets.

## Back to the server

When faced with the reality of $400/yr vs. $120/yr, the proposition is getting
a revised look. This is, after all, a hobby. Nobody visits this site. I do
it strictly out of interest, because I enjoy it and I believe in it.

So I broke out the [ansible scripts][scr] and went to work on building a
new server to roll over to.

Today I learned to do

    echo >>/etc/profile.d/setlocale.sh "export LC_CTYPE=POSIX"

as root, in order to eliminate the "Unable to set LC_TYPE" warnings.

There are problems with those ansible scripts. 
- The login as root check has never worked well. I have to separate that to a
  second task. My solution was to delete it from the play after it had run.
- The iptables stuff is broken for Debian because they've moved to nftables.
  I deleted this part and then set-up nftables manually.
- It wouldn't install passenger

There are problems with the Capistrano install.
- I needed to make installs of rbenv, ruby, etc. for the user, not for
  the machine. That is "local" installs for the user logged-in for
  making the install (not root).
- It wouldn't run the bundler because it used a bad path, ".rbenv/bin".
  I had to create a symbolic link there to "/usr/bin".
- The assets precompile seems to never work. It isn't working because the
  program isn't going to work, either; because the shared library for
  davenport isn't installed in a way or form that will load properly.

[scr]: https://github.com/wbreeze/ansible-server-setup#readme
[awsp]: https://docs.aws.amazon.com/pricing-calculator/latest/userguide/what-is-pricing-calculator.html
[travis]: https://docs.travis-ci.com/user/languages/ruby
[hk]: https://www.heroku.com/ruby
[eb]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_Ruby.html
[ec2]: https://aws.amazon.com/ec2/
[rds]: https://aws.amazon.com/rds/
[amp]: https://aws.amazon.com/amplify/
[ror]: http://rubyonrails.org/
[ln]: https://www.linode.com/
[sc]: https://socelect.org/
[scsrc]: https://github.com/wbreeze/socelect
