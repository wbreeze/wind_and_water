---
layout: post
title: RSpec have HTTP status upgrade
date: 2018-02-23
categories: rspec rails upgrading
---
When upgrading a project to the Rails 5.2 pre-release we started to see
some deprecation warnings in our RSpec runs.
The warnings were as follows, and occurred wherever
`have_http_status(:success)` or `have_success_status` and the like
were used in tests.

```
.DEPRECATION WARNING: The success? predicate is deprecated and will be removed
in Rails 6.0. Please use successful? as provided by Rack::Response::Helpers.
(called from matches? at rspec/rails/matchers/have_http_status.rb:263)
```

This was annoying because many controller tests use
the `have_success_status` matcher.

## What changed
Rails, with [this commit](https://github.com/rails/rails/pull/30104/files)
decided, in very reasonable fashion, to standardize the response status
checking methods in ActionDispatch::TestResponse.

The team simply deprecated the `success?`, `missing?` and `error?` methods
with the suggestion to use the `successful?`, `not_found?`,
and `server_error?` methods pre-existing in
[`Rack::Response::Helpers`](
https://github.com/rack/rack/blob/b37356ee881c0de4266165dacb8af4efaebaf4ec/lib/rack/response.rb#L110).
(`ActionDispatch::TestResponse` inherits from `ActionDispatch::Response` which
includes `Rack::Response::Helpers`.)

In `rspec-rails`, the `have_http_status` matcher called these methods
in a meta-sense, by mapping the `:success`, `:missing`, and `:error`
symbols to corresponding methods invoked on the response.

## How to repair?
One way to repair this would have been to support the replacement methods,
e.g. `successful?` and require any extant tests using, for example,
`have_http_status(:success)` to make the change to
`have_http_status(:successful)`.

This would possibly be defensible as a "follow closely as a thin wrapper on
Rails" strategy. Unfortunately, it would break a mountain of tests!

The [method provided](https://github.com/rspec/rspec-rails/pull/1951)
settles with doing a version check on Rails.
It also introduces the new status codes, `:successful`, `:not_found`,
and `:server_error` while maintaining support for the Rails deprecated ones.

Prior to 5.2 it maps `:success` or `:successful` to the `success?` method.
From 5.2 and later it maps the same to the `successful?` method.

Thus the world of `rspec-rails` turns in accordance with the heavens,
that is, Rails.
