---
layout: post
title: Tracking the source of a fork
date: 2018-03-21
categories: git forking
---

In Ruby land, we usually take advantage of open source through the
published gems. Sometimes it's nice to use open source from the source.
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

One way to do this is to fork the source, make a production branch
for your localized modifications, and have the master branch track
the source.
With this setup, you can pull source improvements in the master branch,
then merge or cherry-pick those into your production branch.

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
> -m master -t master \
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
remote.source.fetch=+refs/heads/master:refs/remotes/source/master
```

We want to make the master branch track the source from `cdriehuys`.
First we fetch the branches from the source, then set the upstream
branch for master.

```
~/ansible/roles/lock-root[master]$ git fetch --all
Fetching origin
Fetching source
From github.com:cdriehuys/ansible-role-lock-root
 * [new branch]      master     -> source/master
~/ansible/roles/lock-root[master]$ git branch --set-upstream-to=source/master
Branch 'master' set up to track remote branch 'master' from 'source'.
```

The `git config -l` output shows that the master branch now tracks
the master branch from `cdriehuys`.

```
remote.origin.url=git@github.com:TelegraphyInteractive/ansible-role-lock-root.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=source
branch.master.merge=refs/heads/master
remote.source.url=git@github.com:cdriehuys/ansible-role-lock-root.git
remote.source.fetch=+refs/heads/master:refs/remotes/source/master
```

Note that the master branch is now "read-only." We won't be able to push
from the master branch, because we do not have write access to the source
repository. We **can** however do `git pull`. The pull will bring any upstream
changes from `cdriehuys` into our workspace.

The only thing left to do is make our own branch based on our own repository,
so that we can make changes. Let's call the branch, `production`.
First we create the branch and switch to it at the same time.
Next we push the branch to our own repository, the `origin` and set
that as the "default," upstream branch for all future pushes.

```
~/ansible/roles/lock-root[master]$ git checkout -b production
Switched to a new branch 'production'
~/ansible/roles/lock-root[production]$ git push --set-upstream origin production
Total 0 (delta 0), reused 0 (delta 0)
To github.com:TelegraphyInteractive/ansible-role-lock-root.git
 * [new branch]      production -> production
Branch 'production' set up to track remote branch 'production' from 'origin'.
```

The output of `git config -l` now shows the new `production` branch
tracking our own repository.

```
remote.origin.url=git@github.com:TelegraphyInteractive/ansible-role-lock-root.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=source
branch.master.merge=refs/heads/master
remote.source.url=git@github.com:cdriehuys/ansible-role-lock-root.git
remote.source.fetch=+refs/heads/master:refs/remotes/source/master
branch.production.remote=origin
branch.production.merge=refs/heads/production
```

When we want to pull upstream changes, we go to the master branch
and pull them.

```
~/ansible/roles/lock-root[production]$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'source/master'.
~/ansible/roles/lock-root[master]$ git pull
Already up to date.
```

We can now get a view of the changes made upstream on the master
through `git log` and `git diff`.

Satisfied with the changes, we can merge, cherry-pick or
[(gulp) rebase](/2018/03/rebase-v-merge.html)
the changes we have in production:

```
~/ansible/roles/lock-root[master]$ git checkout production
Switched to branch 'production'
Your branch is up to date with 'origin/production'.
~/ansible/roles/lock-root[production]$ git merge master
Already up to date.
```

This gives us the best of two worlds, don't you think?
Who says you can't have your cake and eat it too?

Well. There's one source of error.  Now it's necessary to leave
the directory checked-out to the production branch. If we accidentally
leave it checked-out to the master branch, all of our hard work will
be for naught, and we might face some confusing errors.

The other complication is that we'll now have to work with
[git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
Assuming the project we are working is under source control with git,
we've just checked-out another git repository within it.

There's some care required with making changes to submodules in a project.
If it isn't worth the trouble, forget everything you've read and copy copy
copy! (It's the sincerest form of flattery.)