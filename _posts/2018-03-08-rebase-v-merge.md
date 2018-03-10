---
layout: post
title: Git merge v. rebase
date: 2018-03-08
categories: git teams kiss religion
---

I’ve been looking into the git merge v. rebase endless theological debate.
It comes up over and over. But I’ve only ever gotten into trouble
trying to rebase. Not getting all wrapped up over how my
commit history looks and just merging has given me fewer issues.

I’m seeing a camp that recommends rebasing your local feature branch when
master gets ahead of it, but merging it when you bring it back into master.
Another person says, yeah, do that, but if your rebase has conflicts,
give it up and merge instead.

I’ll paste some links now. …

- [SO: Conflict resolution during rebase](
  https://stackoverflow.com/a/11219380/608359)
- [Atlassian article](
https://www.atlassian.com/git/articles/git-team-workflows-merge-or-rebase)
  has pros and cons and what Atlassian does.
- [SO: When to rebase](https://stackoverflow.com/a/36587353/608359)
- [Atlassian tutorial](
https://www.atlassian.com/git/tutorials/merging-vs-rebasing)
Contains "The Golden Rule of Rebasing" and after two thousand words says,
"that’s all you really need to know to start".

The gist I’m taking away is that it’s okay (but entirely optional) to rebase
your feature branch occasionally before finally **merging** it back to master.

All of the caveats and warnings I’m seeing in these threads are about rebase.
That tells me something. My friend, KISS says, "Just merge and stop fussing."
