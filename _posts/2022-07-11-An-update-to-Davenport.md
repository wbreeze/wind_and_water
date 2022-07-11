---
layout: post
title: An update to Davenport
date: 2022-07-11
lang: en
categories: programming davenport
excerpt:
---

I'm trying to spin-up a new instance of [socelect.org][soc] and need to
compile the [Davenport library][dlib] for it.

This was a bit of an eye opener. I myself wasn't able to do it. How do I expect
anyone else to? The install simply wouldn't work.

![Well now, this is embarrassing.][xkcd]

The reason for this is that I had not tested the install "from scratch" since
writing the command line program for trying-out the library. When installing
from nothing, from a `git clone` of the source, there's a [Catch 22][22].
The command line program won't compile without the library. The library
won't compile because the command line program won't compile.

Well now, this is embarrassing.

To fix it meant some fiddling with [GNU Autoconf][ac] and some directory
reorganizing. More than a little fiddling, actually. About a day's worth.

It isn't perfect, what I came up with. Now 
the need for the [Cutter][cutter] testing library is confined to compiling
the tests. The command line executable will not compile without first
compiling and installing the davenport library. However, that is now
possible, more straightforward.


### Aside, CMake

As an aside, while web searching an error message I found [an answer on
askUbuntu][ask] in which a user with name, "Qix" begs people not to use
the [GNU Autoconf][ac] tool chain. They want people to use [CMake][cmake]
instead. Looking at that, wow. It's a whole new beginning.

[CMake][cmake] is one of those open source, "free" software efforts that
supports itself with training. This always signifies to me that it isn't free,
that the documentation you need to truly get up to speed with it is in courseware
or courses that you have to pay for. A quick look gave me some validation of
that suspicion. I didn't find a "Getting started" document, for example, nor
any kind of overview. The docs were reference materials that went straight
down into the weeds.

This isn't entirely a fair assessment. There's a book available online via
the menu, [_Mastering CMake_][mcm]. There's nothing wrong with making money
by producing a good product and offering consulting for it.

[mcm]: https://cmake.org/cmake/help/book/mastering-cmake/
[ask]: https://askubuntu.com/questions/27677/cannot-find-install-sh-install-sh-or-shtool-in-ac-aux
[cmake]: https://cmake.org/cmake/help/latest/manual/cmake.1.html
[ac]: https://www.gnu.org/savannah-checkouts/gnu/autoconf/autoconf.html
[22]: https://dilbert.com/strip/2015-09-22
[xkcd]: https://imgs.xkcd.com/comics/circuit_diagram.png
[soc]: https://socelect.org/
[dlib]: https://github.com/wbreeze/davenport
[cutter]: https://cutter.osdn.jp/
