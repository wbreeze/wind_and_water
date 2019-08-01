---
layout: post
title: Davenport's Algorithm
date: 2019-08-01
categories: software socelect davenport rank-aggregation
---

This is the third in a series of posts about the development of
[socelect.org](https://socelect.org). Find the first here,
[introducing socelect]({% link _posts/2019-07-30-socelect.md %}).

Davenport's algorithm, developed in the early oughts by Andrew Davenport
in the math department at IBM TJ Watson Research center in Yorktown Heights,
New York, provides a practical way to compute a Kemeny-Young preference
ranking from some number of individual preference rankings.

## Kemeny-Young Preference

Suppose you have half a dozen alternatives ranked
in terms of preference, most to least, by any number of interested parties.
The Kemeny-Young method selects an overall ranking that contains the least
number of pair-wise disagreements with the individual rankings.

Here is an illustration of "least number of pair-wise disagreements."
Suppose, given three alternatives, Budd, Ace, and Rickie, you receive
preferences as follows:

- 29 have Ace before Budd and then Rickie
- 31 have Budd before Ace and then Rickie
- 40 have Rickie before Ace and then Budd

![preference graph]({% link /assets/davenport/abr_pref.svg %})

<p style="clear: both"/>

- Placing Ace before Budd and then Rickie scores 111 disagreements:
    - 31 disagreements with those that placed Budd before Ace plus
    - 40 disagreements with those who placed Rickie before Budd plus
    - 40 disagreements with those who placed Rickie before Ace
- Placing Budd before Ace and then Rickie scores 169 disagreements:
    - 69 disagreements with those that placed Ace before Budd plus
    - 60 disagreements with those who placed Budd before Rickie plus
    - 40 disagreements with those who placed Rickie before Ace
- Placing Rickie before Ace and then Budd scores 131 disagreements:
    - 31 disagreements with those that placed Budd before Ace plus
    - 60 disagreements with those who placed Budd before Rickie plus
    - 40 disagreements with those who placed Rickie before Ace

There are three more possible orderings. You can count them up yourself
and see that they have 131, 169, and 189 disagreements.

The Kemeny-Young preference is thus Ace before Budd and then Rickie,
because that ordering gives the least number of disagreements.
This makes intuitive sense. The least number of people are offended
by anything in that ranking. To put it the other way around, it is
the ranking that satisfies the most people.

John Kemeny at Dartmouth College in Hanover, New Hampshire
developed the concept and published it in 1959.
Peyton Young when at the Systems and Decision Sciences Division at the
Institute for Applied Systems Analysis, Austria (now at Oxford University in
England), proved in 1978 that
the Kemeny order is a maximum likelihood estimator of the true preference.
In plain terms, that means it is the ranking most likely to represent
the preference of the group.

As a side note, if the above was an election and you were selecting
one winner,
plurality vote would select Rickie (the least preferred).
A runoff election between
the top two would eliminate Ace. The Ace followers specified Budd next,
and would likely transfer their votes to him in the runoff, electing Budd.
An instant runoff election that transferred Ace's votes to Budd would
choose Budd.
The candidate most preferred, that most would be happy with,
by examination and by Young's proof, is Ace.

Do you see why I think Kemeny-Young preference ranking is the best thing
since popcorn? The bee's knees? Cake and ice cream? Almost as good as
apple pie?

The contribution of Davenport was to develop an algorithm that doesn't
require trying and measuring every possible ranking. With three alternatives
we have six possible rankings. With only a dozen alternatives there are
nearly half a billion. The numbers fairly quickly become astronomical,
Carl Sagan numbers.

## Davenport's Algorithm

The algorithm makes finding Kemeny-Young preferences tractable by quickly
ruling-out prefixes of the rankings. If you choose the first, second, and
third ranked alternatives and see that it will already lead to a number
of disagreements higher than the lowest numbered solution you've yet found,
there's no need to look at any more rankings that begin with those three.

The technical term for this ruling-out process is "bounding", or "pruning
search using a lower bound."

The second thing that makes Davenport's algorithm work well is use of a
very good heuristic (rule of thumb) for selecting which alternatives
to try first.
It tries alternatives first that have the greatest majority of preference
over all of the others.

![majority graph]({% link /assets/davenport/abr_maj.svg %})

In the example, Ace has a majority of (60 - 40 = 20) over Rickie and
(69 - 31 = 38) over Budd for a total of 58. Budd's majority is 20,
Rickie's is zero. You see how strong this heuristic is.

The lower bound computation goes like this. Once you reach the possible
rankings with Rickie as the first choice, how far do you have to go before
seeing that rankings starting with Rickie will never have a lower number
of disagreements than the one found with
111 disagreements
(Ace before Budd and then Rickie)?

![Rickie disagreements]({% link /assets/davenport/abr_rdis.svg %})
![Budd disagreements]({% link /assets/davenport/abr_bdis.svg %})

When you choose Rickie first, you immediately have 120 disagreements.
There's no need to explore any further. All rankings that start with Rickie
may be pruned, eliminated from consideration.

When you choose Budd first,
you immediately have 109 disagreements. To that, you can add the minimum
number of disagreements that will result from ordering Ace and Rickie
after Budd. That number is 40. Thus, starting with Budd you have a lower
bound of 149. All rankings that start with Budd may be pruned.

The pruning is not such a big deal with three alternatives, but with
dozens of alternatives, it is essential.

The next contribution that Davenport made with his algorithm was computation
of a strong lower bound. By "strong," we mean it is as low as you can possibly
make it without being lower than the true lowest valued result, as in,
not wrong.

![majority graph]({% link /assets/davenport/abrc_maj.svg %})

Davenport used a method from capacity planning for computing maximum flow.
He modeled the problem using a majority graph, which has nodes (places)
corresponding to alternatives and directed edges (arrows) weighted with
the majority preference for one alternative over the other. Computing
maximum flow through all three-cycles in this graph gives the minimum
majority that must be broken in order to break the cycles and rank the
alternatives.

Two years later, in 2006, Davenport teamed up with IBM Post-doctoral visiting
scientist Vincent Conitzer (Ph.D. at Carnegie Mellon University in Pittsburgh,
Pennsylvania; now a professor at Duke University in Durham, North Carolina)
to improve the lower bound (make it stronger) by
accounting for three-cycles that shared an edge in the graph.

## Closing

Here I went using all of the space in this post to explain Kemeny-Young
preference aggregation and Davenport's algorithm. Next time I'll write about
the implementation.
