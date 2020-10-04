- Everything in Docker
Docker is cool. It allows creating portable, repeatable environments for both
development and production. But.
  - With microservices you're going to have a lot of them. And then you'll be
  using and managing Docker-compose configurations. And then you'll want
  Kubernetes to orchestrate all of it into deployment.
  - It slows down developers. They have to run everything in containers.
  With fifteen containers, things start to bog-down a bit, even on a pretty
  nice Mac. The people using Linux have a little better time of it, but it's
  still slower than being on the bare OS.
  - Developers end-up keeping terminals inside of the containers, which is
  not quite the same as having an SSH terminal in a remote machine, but half
  a step toward it, as in, not my OS terminal prompt, not my OS tools.
  - You have to manage the file system mappings so that things like database
  files don't reset every time a container is dropped.
  - You end-up managing differences in production and development configurations
  anyway, because they're always configured a little bit differently.
  - You still need documented set-ups for developers. Just the same as
  if they're setting-up on bare machines.

- You think the services are independent, but inevitably id's and other
data or metadata creep across from one service into another.
A service retrieves some data from another, does some work, needs some of
that data to do follow-up calls. Or then, worse, it needs to store an id
or other data together with its own data in order to maintain an association.
This is one way in which the boundaries between services blur, and
co-dependencies develop.

- Silos develop. Depending on how you manage. However even if every developer
is allowed to change any of the services, it's easier to develop an affinity
with some services over others, vs. living wholly in the monolith.
If you allow different services to use different stacks, which is an advantage
sometimes put forth for microservices, you'll find that developers slow down
when crossing stacks. Being expert in multiple stacks takes a lot of years.
Being current in multiple stacks is pretty tough, because it can be difficult
to keep up with one.

- Testing is brittle. You'll need to simulate requests and responses from
other services. When the simulations no longer have similitude, your tests
are no longer valid. You don't get to find out in test that a request or
response format changed. For that, you need integration tests that in fact
call the other service endpoints. For that, you have to configure and run
those services in the testing environment.


