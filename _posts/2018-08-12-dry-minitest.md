---
layout: post
title: Keeping minitest Dry
date: 2018-08-12
categories: minitest testing dry "clean code"
---
Here's a test written with
[minitest](https://github.com/seattlerb/minitest)
as extended for Rails.([Footnote](#footnote))
It is from the open source Rails project,
[IACCDB](https://github.com/wbreeze/iaccdb).

```
require 'test_helper'

module Admin
  class MemberControllerTest < ActionController::TestCase
    setup do
      @member_list = create_list(:member, 12)
      @before_attrs = @member_list.first.attributes
      @after_attrs = @before_attrs.merge(
        {'family_name' => Faker::Name.last_name}
      )
    end

    test 'non-admin cannot view index' do
      get :index
      assert_response :unauthorized
    end

    test 'non-admin cannot show member' do
      get :show, params: { id: @member_list.first.id }
      assert_response :unauthorized
    end

    test 'non-admin cannot patch update' do
      patch :update, params: { id: @after_attrs['id'], member: @after_attrs }
      assert_response :unauthorized
    end

    test 'admin can get index' do
      http_auth_login(:admin)
      get :index
      assert_response :success
    end

    test 'admin can get show' do
      http_auth_login(:admin)
      get :show, params: { id: @member_list.first.id }
      assert_response :success
    end

    test 'admin can patch update' do
      http_auth_login(:admin)
      patch :update, params: { id: @after_attrs['id'], member: @after_attrs }
      assert_response :redirect
      member = Member.find(@after_attrs['id'])
      assert_not_nil(member)
      assert_equal(@after_attrs['family_name'], member.family_name)
    end

  end
end
```

The test validates that an unauthenticated user cannot access some
member administration controller methods.
It validates that an authenticated user can access the methods.

A few things about this test file are troublesome:

- Primarily, I don't like the repetiton of `http_auth_login(:admin)`
  at the front of each of the authenticated tests.
- There is some repetition in the test naming: "non-admin cannot",
  "admin can"
- There are two groups of tests here that aren't in any way grouped.
  Each group calls the same endpoints with different setup and expected
  results.


## thoughtbot/shoulda-context

One solution is to use the
[thoughtbot/shoulda-context](https://github.com/thoughtbot/shoulda-context)
gem.
The shoulda-context gem adds some DSL to minitest for defining contexts of
tests. Now the non-admin tests and the admin
tests each have their own context group. The admin context group has
additional setup that arranges the http basic authentication.

Here is a link to a
[commit with the diff](
https://github.com/wbreeze/iaccdb/commit/f7f8e3c08ca3856ae70545abca097cde195d51cc)
that shows all of the changes. It adds the gem and includes the DSL
additions for all tests in the `test_helper.rb` file.

Here is the new test file. The test implementations themselves did not
change, and are omitted here. The structure of the test file changed with
`context` and `should` DSL methods.
You can find an additional `setup` block within the
`allow admin` context that takes care of authenticating the
admin user for that context.

```
require 'test_helper'

module Admin
  class MemberControllerTest < ActionController::TestCase
    setup do
      @member_list = create_list(:member, 12)
      @before_attrs = @member_list.first.attributes
      @after_attrs = @before_attrs.merge(
        {'family_name' => Faker::Name.last_name}
      )
    end

    context 'deny non-admin' do
      should 'get index' do
        # ...
      end

      should 'get show' do
        # ...
      end

      should 'patch update' do
        # ...
      end
    end

    context 'allow admin' do
      setup do
        http_auth_login(:admin)
      end

      should 'get index' do
        # ...
      end

      should 'get show' do
        # ...
      end

      should 'patch update' do
        # ...
      end
    end
  end
end
```
This is more satisfying because it:

- Calls out that we're testing the same endpoints with two setups
- Avoids repeating the `http_auth_login` call on each of the authorized tests
- Avoids repeating `deny non-admin` and `allow admin` in the test names

#### Footnote
Rails adds some DSL shortcuts through ActiveSupport::TestCase for defining test
methods with `test`; defining setup and teardown methods with
`setup` and `teardown`.
