---
layout: post
title: Tracking the source of a fork
date: 2018-03-21
categories: git forking
---

In Ruby land, we usually take advantage of open source through the
published gems. Sometimes however, it's nice to use open source from the source.
Sometimes you want to run off of a fork, but track
changes and improvements made to the source.
Here are a couple of scenarios:

* You need to make some changes for your project that don't have a prayer
of making it back into the source. That is, you expect to run from the
fork more or less permanently, without requesting the source provider to
pull your very specialized changes.
* You don't trust the source not to disappear, or not to quietly introduce
malicious code in an update.

How do you have your cake and eat it too? How do you run a customized
fork while tracking improvements made to the original?

(This following is a rewrite of the original post, see [note](#note).)

One way to do this is to fork the source, make a special branch that
tracks the source of the fork, and occasionally pull, then merge
or cherry-pick from that branch.

Here's how it works. We're going to pick-up an Ansible role from GitHub.
Let's use, `cdriehuys/ansible-role-lock-root`.

First, fork the role in GitHub. The name of our fork is,
`TelegraphyInteractive/ansible-role-lock-root`.

Now we clone:

```
~/ansible/roles$ git clone \
> git@github.com:TelegraphyInteractive/ansible-role-lock-root.git lock-root
Cloning into 'lock-root'...
~/ansible/roles$ cd lock-root
~/ansible/roles/lock-root[master]$
```

We cloned inside of the `roles` directory of our Ansible playbook, but
that is an irrelevant detail. We also changed the name to keep it short.
The cloned repository exists in directory, `~/ansible/roles/lock-root`.

The `git config -l` output contains these `remote` and `branch`
settings:

```
remote.origin.url=git@github.com:TelegraphyInteractive/ansible-role-lock-root.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
```

We want at least one branch to track the master branch from the original
source, `cdriehuys/ansible-role-lock-root`. In order to do this, we first
have to make that repository available as a remote.
We create a remote called, `source`:

```
~/ansible/roles/lock-root[master]$ git remote add \
> source 'git@github.com:cdriehuys/ansible-role-lock-root.git'
```

The `git config -l` output now contains the additional remote
called, `source`.

```
remote.origin.url=git@github.com:TelegraphyInteractive/ansible-role-lock-root.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
remote.source.url=git@github.com:cdriehuys/ansible-role-lock-root.git
remote.source.fetch=+refs/heads/*:refs/remotes/source/*
```

We want to make a branch that will track the source from `cdriehuys`.
First we fetch the branches from the source.

```
~/ansible/roles/lock-root[master]$ git fetch --all
Fetching origin
Fetching source
From github.com:cdriehuys/ansible-role-lock-root
 * [new branch]      master     -> source/master
```

Next we create a branch, `super` that tracks branch `master`
from the source.

```
~/ansible/roles/lock-root[master]$ git branch -t super source/master
Branch 'super' set up to track remote branch 'master' from 'source'.
```

The `git config -l` output shows that the super branch now tracks
the master branch from `cdriehuys`.

```
remote.origin.url=git@github.com:TelegraphyInteractive/ansible-role-lock-root.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
remote.source.url=git@github.com:cdriehuys/ansible-role-lock-root.git
remote.source.fetch=+refs/heads/master:refs/remotes/source/master
branch.super.remote=source
branch.super.merge=refs/heads/master
```

Note that the super branch is "read-only." We won't be able to push
from the super branch, because we do not have write access to the source
repository. We **can** however do `git pull`. The pull will bring any upstream
changes from `cdriehuys` into our workspace.

When we want to pull upstream changes, we go to the super branch
and pull them.

```
~/ansible/roles/lock-root[production]$ git checkout super
Switched to branch 'super'
Your branch is up to date with 'source/super'.
~/ansible/roles/lock-root[super]$ git pull
Already up to date.
```

We can now get a view of the changes made upstream on the source
through `git log` and `git diff`.

Satisfied with the changes, we can merge, cherry-pick or
[(gulp) rebase](/2018/03/rebase-v-merge.html)
the changes we have in master:

```
~/ansible/roles/lock-root[master]$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
~/ansible/roles/lock-root[production]$ git merge source
Already up to date.
```

This gives us the best of two worlds, don't you think?
Who says you can't have your cake and eat it too?

#### Note
The original post arranged for the master branch to point to the origin
from which we forked. This was painful in many ways, especially when
checking-out the project for the first time:

 - The default master was not present, so the `git clone` had to specify
   a branch.
 - Reconstituting the elaborate setup dealt a lot of complicated rework.

Hoping this is simpler and apology for misleading anybody.
Rewrite date, September 12, 2018.
