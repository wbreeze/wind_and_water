---
layout: post
title: SCCM and Git
date: 2019-01-09
categories: rails node.js git sccm
---
There are files in our software systems that we desire to have under
source control, but which we never edit. These are source code configuration
management (SCCM) files such as `Gemfile.lock`, `npm.shrinkwrap.json`,
or `db/schema.rb`.

We keep these files under source control (e.g. git), but should we
allow git to merge them when there are independent changes?
If this looks "tl;dr", jump now to the conclusion.

Three examples in a [Rails](https://rubyonrails.org/) application are
the `Gemfile.lock` for capturing the configuration of Ruby Gems
and `db/schema.rb` or `db/structure.sql` files that capture the schema
for the database.

An example in a [node.js](https://nodejs.org/en/) application is the
`npm.shrinkwrap.json` file that captures the configuration of Node packages.

We don't edit these files because they are generated by the development
platform as artifacts that capture software configuration.
We keep them under source control, in git, because they capture the current
configuration of dependencies, or of database structure, etc. for the
software system.

## Merging configuration files
So what happens when two developers make a change which requires regeneration
of one of these files? To be concrete, suppose two developers individually
update a gem using the `bundler` program, generating independent
versions of `Gemfile.lock`.

Whichever of these developers is second to commit, they will have to first
merge the other's changes. Here is the ten dollar question: do we allow
git to merge the two versions of `Gemfile.lock`?

To answer it, let's consider:
- Would you think of editing this file by hand? Generally not.
- Will the git merge produce a file identical to the one that would result
if one developer had made both changes? Maybe. Maybe not.
- If git produced a merge conflict, would you reconsider editing by
hand to resolve the conflict? Would you be sure of the result?
- Suppose instead we're talking about the database schema. Are you certain
that merge will always produce the schema that would result if one
developer had made both changes?

Thinking about those questions, it seems prudent not to allow git to
merge these files. What we would prefer is that git leave our version
intact, announce that there is a conflict, and not commit the merge
until we have resolved it.

### Preventing automatic merge by git
We can tell git not to merge a file using the `.gitattributes` file.
The `.gitattributes` lives next to the `.git` directory in the root
of our project (and does not exist unless we create it).

The `man gitattributes` command produces a
[long list](https://www.git-scm.com/docs/gitattributes)
of configuration
options we can set for files managed by git. One of them is the "`merge`"
attribute, found under the heading, "Performing a three-way merge".
Using the setting as follows:
```
Gemfile.lock -merge
```
in `.gitattributes` will unset merge for Gemfile.lock. Thus git will
"Take the version from the current branch as the tentative merge result,
and declare that the merge has conflicts."

The setting,
```
Gemfile.lock merge=binary
```
in `.gitattributes` will set merge to binary mode for Gemfile.lock. Thus
git will "Keep the version from your branch in the work tree,
but leave the path in the conflicted state for the user to sort out."

Either method provides the desired result. In fact, they sound the same.
However it's easy to experiment.

With `Gemfile.lock -merge`, on a conflict, we get the following:

```
warning: Cannot merge binary files: Gemfile.lock (HEAD vs. <commit-id>)
Auto-merging Gemfile.lock
CONFLICT (content): Merge conflict in Gemfile.lock
Automatic merge failed; fix conflicts and then commit the result.
```
The `Gemfile.lock` file has the content from the local (our) version.
The `git status` command yields:
```
On branch master
Your branch and 'origin/master' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" to merge the remote branch into yours)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

	both modified:   Gemfile.lock

no changes added to commit (use "git add" and/or "git commit -a")
```

With `Gemfile.lock merge=binary`, on a conflict, we get identical outputs
and the file itself is treated identically.

## Resolving the conflict
Resolution of the conflict means running whatever process is in place
for generating these files, in order to produce the generated content
as it should be. The artifacts from which these files are derived are
present in the merged result.

With `Gemfile.lock`, the independent changes to `Gemfile` have been merged.
(If there is a conflict for that file, we resolve it.) Then all we need
do is run bundler and add the resultant file to the merge:
```
bundle install
git add Gemfile.lock
```

The case for an `npm.shrinkwrap.json` file is analogous. The independent
changes to `package.json` have been merged. Running `npm install` will
generate a new shrinkwrap file that we can add to the commit.

With the database schema files managed by Rails, we picked-up the other
developer's new migration in the merge. We run `rails db:migrate` to
not only make the needed changes to local development and test databases,
but also to produce a new `db/schema.rb` or `db/structure.sql` file that
we add to the merge commit.
See [Merging migrations]({% post_url 2018-03-09-merging-structure %})
for full details.

## Conclusion
In order to properly manage generated SCCM files with git, we:
1. use the `.gitattributes` file to tell git not to merge them, ever,
but rather announce that there is a conflict.
2. use our tooling to regenerate the files from the merged assets.
3. add the newly generated files to the merge commit.
