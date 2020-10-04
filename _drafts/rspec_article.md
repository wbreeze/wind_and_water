## Information (probably not a good example)

Consider
```
describe 'GET #new' do
  context 'when there is no authenticated user' do
    subject! { get :new }
    it { is_expected.to be_unauthorized }
  end
end
```
It's very pretty. Nicely succinct. Spare. Other than that mysterious bang,
pretty clear.

But now I get back,
```
expected `#<ActionDispatch::TestResponse:...>>>>.unauthorized?` to return true, got false
```

What can I do to see what *was* returned?

A print statement in the controller would be simple enough, but this is authentication,
buried deep down in rack middleware somewhere. The code never even hits the
`new` method. It get's bumped out in a `before` hook.

Here's what I do:
```
  describe 'GET #new' do
    it 'returns unauthorized when there is no authenticated user' do
      response = get :new
      expect(response).to have_http_status :unauthorized
    end
  end
```
and the test helpfully returns
```
expected the response to have status code :unauthorized (401) but it was :found (302)
```
Now I know that there's an authentication problem.
And there's no mysterious bang in `subject!`.
There's no "it" to infer from, `it { is_expected ...`.

- What is "it?"
- What "is_expected?"
- Oh, the invisible whatever returned by the code inside of `subject!`, ah!
- We the initiated DSL experts know that well enough. What's *your* problem?

There's no need for inference in the second construction.
I know that we're reasoning about the response.
I know that, because I know Ruby.

### What I ended up doing
I ended up deleting the spec, because controller spec's aren't designed
to test failure of authentication. We had a request spec for that.
The tested controller method prior had not required authentication,
and I was trying to reversing it when it no longer made sense to have it.

## The need for let bang
In the following setup for a feature spec testing a list
```
  let(:user_count) { 24 }
  let!(:users) { create_list(:user, user_count) }
  let(:auth_user) { create(:user) }
  let(:total_users) { user_count + 1 }
  before :example do
    authenticate_as(auth_user)
    visit users_path
  end
```
we have a bang version of `let`, `let!(:users)`

Without the bang, the following test fails
```
  it 'lists the users' do
    user_lines = page.all('tbody tr.index')
    expect(user_lines.count).to eq(total_users)
  end
```
Why? Because nothing in the test asks for `users`. Because of lazy
initialization `users` is never invoked.

Without the bang:
- The test will always fail when we run it individually.
- When we run the test file as a whole, with random ordering,
the test will sometimes fail depending whether another test
accessed `users`.

Most of the time, I'll trip on this and put in the bang.
However the need for a bang version of `let` let's me know that
sometimes what `let` is doing for me (lazy initialization) is
actually something that it's doing *to* me.

