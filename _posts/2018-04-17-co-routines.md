---
layout: post
title: Coroutines
date: 2018-04-17
categories: software
---
Have you ever wondered how a construction crane grows with the building?
Well, I have. Here's how it works.

A portable crane constructs the initial tower and places the head, with
pivot and counter-balanced long arm, on top. Then the crane starts making
the building.

When the building reaches a height too close to the height of the crane,
the crew stabilizes the tower using a brace against the building.
Then they add sections, about four meters long,
to the tower underneath the head.

![Preparing to extend the crane](/assets/images/CraneConnected.jpg)
![Crane extended](/assets/images/CraneExtended.jpg)
![Construction crane](/assets/images/Crane.jpg)

This process of adding sections underneath the head is fascinating,
at least to me. It's a very clever work of engineering.

The base of the tower, when it was first constructed, is fitted
with a sleeve.
The sleeve is roughly double the length of a section.
- The upper part of the sleeve can stably hold the head of the crane.
- The lower part of the sleeve can stably maintain itself attached to
the tower and move the sleeve up and down on the tower.
- The middle part of the sleeve is hollow, open on one side, and fitted
with rails and catwalks.

The crew:

1. moves the sleeve up to the head.
1. braces the tower below the sleeve.
1. raises a section of tower using the crane itself,
and stations the section on the rails of the sleeve.
1. raises another section of tower or a weight to use as adjustable balance
for the head.
1. attaches the head to the sleeve and detaches it from the tower.
There is much banging and fiddling at this stage as they move the
crane to balance the head, take pressure off of the bolts, line up the
bolt holes, and remove or insert the bolts.
1. raises the sleeve, with the attached head, leaving an open space
between the head and the tower.
They do this very, very slowly.
There is no perceptible motion, only over time, a widening gap.
1. slides the new section of tower into place and attaches it.

In the two close-up pictures of the top of the crane, you can see
the sleeve in position before and while raising the head of the crane
above the existing tower to make room for a new tower section.

In the far-away picture, the crew has added one new section to the
tower and is preparing to mount the next section onto the rails on
the sleeve.

## As a metaphor

The crane builds the building, and having built the building,
builds itself. So clever.

This is something like co-routines in software, which trade work
on two parallel aspects of a task to make progress toward completion.

It is also something like bootstrapping a company. You could think of
the crane as money, and the building as the business. With some initial
money you start the business. When the business grows it can fund
itself for more growth.

Seeing the building go up makes me think of incremental development.
A software system isn't
anything like as regular as the floors of a building. As a building,
software would look more like something from Dr. Seuss.
However, in a sense, adding a floor is a sprint. Extending the tower
is a short sprint or spike to enable more sprints.
Filling-out the floors with fire-protection, plumbing, electrical,
HVAC, walls, ceilings, fixtures, and furnishing may all be planned as
units of work or stories that are no doubt sequenced
and scheduled by the builders.

The metaphor is limited:
- A software system ought to be useful very
early in development, like a shed, then a house, then an office, then
a mall... or whatever. The building isn't useful until it's very nearly
complete. (Other than as bracing for the crane that's building it.)
- It's horrible to try to apply construction planning and scheduling
techniques to software. Software isn't regular enough or made-up of
repeated processes- like laying-in sprinkler pipes on the floor of a
building.

In any case,
it's fun to see a construction crew make progress on a building,
to see a crane bootstrap itself, and
to see a development team make progress on a software system.
