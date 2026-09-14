---
layout: post
title: The refactor that made the code say less
date: 2026-09-14
lang: en
categories: software
excerpt: Over two days I took every English sentence out of a small PHP web
  application and put it in a catalogue
---

*with Claude Opus 5 (Anthropic)*

I've been working with this AI software development tool. It has helped
me with a pair of projects over the past few weeks. I'm convinced that
humans don't need to write code anymore. That is a story for another day.
Here is an episode that focuses on the value and the costs of extracting
the human-read content from a code base that renders user interface.

Most of what follows was written by Claude. Maybe you can tell by how
mechanically thorough it is. I read it over, made some tiny little edits.
I can't argue with the correctness and completeness. The conclusion was mine.
Claude was more neutral about it when I asked it to evaluate the refactor.
It gave me costs and advantages. What sealed it was me looking at the code.

## What I did

Over two days I took every English sentence out of a small PHP web application
and put it in a catalogue — a keyed array for the short strings, markdown files
for the prose. Two thousand seven hundred words out of twenty templates, five
hundred and forty\-five more out of a class that assembles a diagnostic panel.
Every screen verified to render identically, before and after, branch by
branch. One hundred and thirty\-eight tests green, a static analyser clean, and
a catalogue of two hundred and twenty keys where the words used to be.

It works. I am going to throw it away.

## What it was for

The site is a demonstrator for on\-chain content metering: a reader connects a
wallet, authorizes a spending limit, and the site draws against it as they
read. Most of what it says is argument rather than furniture — it has to
explain, on the screen where the money moves, what a delegate is, and why
forgetting your wallet is not the same as closing your contract.

So the text matters, and I wanted to be able to work on it. Rewriting a
sentence meant opening a PHP template, finding the sentence among the markup,
and editing around `<?= View::e(...) ?>`. That is a fine thing to want to fix.
The goal was narrow and reasonable: **make editing the English straightforward,
so wordsmithing does not mean touching code.**

It was never about translation. There is no second locale coming. That ruled
out most of the machinery that exists for this — `gettext`, whose key *is* the
English string, so editing the English edits every key; `symfony/translation`,
oversized for one language. What was left was small and bespoke: a `Copy`
class, two files, a key per sentence.

## What it cost, counted

Net **\+1,613 lines** on a demonstrator.

| area | added | removed | net |
| --- | ---: | ---: | ---: |
| `content/ui/` (11 new markdown files) | 601 | 0 | \+601 |
| tests | 424 | 37 | \+387 |
| `config/strings.php` | 373 | 0 | \+373 |
| `src/` | 370 | 102 | \+268 |
| `bin/`, `public/` | 57 | 2 | \+55 |
| **templates** | 445 | 516 | **−71** |

Look at the last row. Two thousand seven hundred words left the templates and
the templates gave back seventy\-one lines. Every screen grew a docblock
paragraph explaining where its words had gone and why. The thing being
optimised did not get smaller; it got quieter.
I'm not going to argue that comments don't count as lines of code.
There's a good case that they do because they can be wrong and bring
maintanence and reading weight.

Of the two hundred and twenty keys, two hundred and four are used exactly
once. That is ninety\-three percent. An argument I leaned onwhile doing this—
a wording fixed in two places is a wording fixed in two places —turns out
to govern only sixteen keys. The duplication was real where it existed (one
heading was rendered four times from two templates; one link had two different
sentences for the same destination) but it is not what the exercise was mostly
doing. Mostly it was moving a string from one file to another and leaving a
name behind.

## Three files, and none of them says anything

Here is the whole of a screen on the old code. It tells you that content is
built ahead of time, that the build has not run, and what to type.

```php
<?php
/** Shown when var/content is missing — a setup problem, so it says how to fix it. */
?>
<article class="piece">
    <h1>Nothing is built yet</h1>
    <p class="lede">
        The content pipeline renders <code>content/*.md</code> ahead of time
        (SPEC §12.7), and it has not run. Its output is deliberately not
        committed.
    </p>
    <pre><code>composer install
bin/build-content
php -S localhost:8000 -t public</code></pre>
</article>
```

Thirteen lines. You can read it. You know what the reader sees, you know why,
and if you want to change the wording you change the wording.

Here is the same screen afterwards:

```php
<?php
/**
 * Shown when var/content is missing — a setup problem, so it says how to fix
 * it. The commands are in `content/ui/not_built.md` with the sentence above
 * them: a fenced block is copy the same way a paragraph is, and splitting the
 * two would put half of this screen in each home.
 *
 * @var \Newsprint\Support\Copy $copy
 */
?>
<article class="piece">
    <h1><?= $copy->line('not_built.heading') ?></h1>
<?= $copy->block('not_built.lede', [], 'lede') ?>
<?= $copy->block('not_built.how') ?>
</article>
```

Fifteen lines. Longer than before, and it no longer tells you anything. To
learn what this screen says you open `config/strings.php` for the heading and
`content/ui/not_built.md` for the two blocks. Three files, for a page that
shows four sentences.

The comment is doing new work, and notice what work: it is explaining the
*mechanism*, not the screen. The old comment explained the screen in one line.
The new one explains why a fenced code block counts as copy. That is the
refactor talking about itself.

## The plumbing is longer than the prose

The meter's unfunded stage, before — a reader has connected a wallet and has no
tokens:

```php
<h2>You will need some <?= $symbol ?></h2>
<p>
    <?= $symbol ?> is minted by this site, on devnet, and is worth nothing.
    It exists so the meter has something real to move.
</p>
<p>
    The faucet gives <?= View::e((string) $meter['faucet']['demo']) ?> <?= $symbol ?>
    and <?= View::e((string) $meter['faucet']['sol']) ?> SOL, once per wallet.
    The SOL is for the rent on your contract account and the fees; the site
    pays for both, and this one does not go through your wallet.
</p>
```

After:

```php
<h2><?= $copy->line('meter.unfunded.heading', ['symbol' => (string) $meter['symbol']]) ?></h2>
<?= $copy->block('meter.unfunded.what', ['symbol' => (string) $meter['symbol']]) ?>
<?= $copy->block('meter.unfunded.faucet', ['demo' => (string) $meter['faucet']['demo'], 'sol' => (string) $meter['faucet']['sol'], 'symbol' => (string) $meter['symbol']]) ?>
```

And, in `content/ui/meter.md`\:

```markdown
## unfunded.faucet

The faucet gives {demo} {symbol} and {sol} SOL, once per wallet. The SOL is for
the rent on your contract account and the fees; the site pays for both, and
this one does not go through your wallet.
```

The markdown is lovely. That is the part that worked, and I will come back to
it. But look at the call site. One hundred and forty characters of argument
plumbing for a sentence you cannot see, and the values arrive by name into
slots you cannot see either — positional substitution, one file away, with
nothing at either end to check that `{sol}` is a number of SOL and not a number
of something else.

Before, the value and the sentence it belonged to were adjacent. You could read
`<?= View::e((string) $meter['faucet']['sol']) ?> SOL` and know it was right.
Now the sentence is in one file, the values in another, and the correspondence
between them is a convention.

## Six rules

None of these existed before. Each was forced by a real case, which is another
way of saying each was discovered the hard way:

1. **Three verbs, chosen by the markup.** `line()` for a label or a button;
   `block()` for a paragraph that is its own paragraph; `inline()` for prose
   that has to come out as an `<li>`, a `<td>`, a `<span>`, or one half of a
   paragraph the template assembles.
2. **The escaping boundary.** Copy that carries markup is never escaped again;
   copy that a template escapes must be plain text. Which means no catalogue
   string in an escaped position may take a placeholder, because a value the
   catalogue escaped would be escaped twice and `a < b` would reach the page as
   `a &amp;lt; b`. Hah! Wrong.
3. **Keys must be literals at the call site**, because a key chosen by a
   ternary is a key no scanner can find.
4. **A `content/ui/` filename is a key prefix, so it must be
   identifier\-safe** — hence `not_found.md` beside `not-found.php`.
5. **A line and a block may not share a key**, since they are separate stores
   and a collision is two strings with one name.
6. **A quotation is not copy** — and if any part of a claim has to match the
   program, the whole claim stays in the code.

Rule six is the interesting one, because it is the boundary failing to be
clean. The site has a diagnostic panel that shows, beside each computed value,
the check in the on\-chain program that the value mirrors:

```php
$rows[] = [
    'required_allowance',
    $amount(Preflight::requiredAllowance($floor)),
    'the SPL delegated amount checked at open and at renew',
];
```

Six of those cells are program expressions — `require!(new_used <= limit,
LimitReached)` — and must stay in the code, because their whole value is that
they match something outside the site. The seventh is that English sentence. So
one cell of seven became:

```php
$rows[] = [
    'required_allowance',
    $amount(Preflight::requiredAllowance($floor)),
    $this->copy->line('inspector.preflight.required_allowance'),
];
```

and a reader of that column now has to know which cells are quotations and
which are prose, and go to a different file for one of the seven. Meanwhile in
the same file `max(min_limit, unpaid carried forward)` stays put, because half
of it is an identifier and half is English. The rule is correct. It is also six
rules deep into a thing that was supposed to make editing easier.

The same asymmetry runs through one template, three lines apart:

```php
<th scope="row"><?= View::e($row[0]) ?></th>
<td class="mirrors"><?= View::e($claim) ?></td>
...
<p class="note"><?= $section['note'] ?></p>
```

Two escaped, one not. Both correct. Neither legible without the rule.

## The counter\-case, at full strength

I want to state what actually worked, because it did.

**Editing prose is genuinely better.** Rewriting a sentence is now one file, no
PHP, no markup to break, and a paragraph splits in two by pressing return.
`content/ui/meter.md` is a pleasure to work in. That was the goal and it was
met.

**Real duplication came out.** *"The rest is metered"* was in two templates and
rendered from four places. *Go to the paper* was in two screens. One explorer
link had two different sentences written "months" apart, which is how I ended up
rewording it to *This transaction on the Solana blockchain ledger* — a change I
only made because the two were finally visible side by side.

**It found two defects that had nothing to do with copy.**
- A pre\-emptive warning gated on *has anything happened* when it meant *has
  this been said*, so one successful advance silenced it for the rest of a
  visit — including the advance that makes the next one certain to fail.
- A failure report with no branch for a revoked delegate, which the
  neighbouring branch was catching and mis\-explaining: an approval that is
  *gone* described as an approval that is merely too small.

Plus a test that could not tell which of three branches had rendered, because
all three opened with the same two words; and a negative assertion —
`assertStringNotContainsString('draft', …)` — that nothing anchored, so it
would have started passing by looking for a string nothing could contain the
day the badge was reworded. That one was not a test.

I first counted four defects rather than two, and the correction is worth
making because it cuts against me.
- A third — a diagnostic panel that ordered its sections by comparing their own
  headings against a literal list — I found by reading, and assumed was
  uncaught. It was not: renaming a heading in one place and not the other turns
  an existing test red, with the displaced section visible in the diff. I
  checked, afterwards, by doing it.
- The fourth was a gap in the scanner that enforces the new convention — a
  defect in machinery the refactor itself had introduced, caught by that same
  machinery, which is not a finding about the application at all.

So: two real defects in pre\-existing code, and two tests made sound. That is
still a real haul for two days. It is half of what I told myself it was.

## Why it does not pay

Here is the thing about those defects: **the refactor was their occasion, not
their cause.** What found them was reading every screen and every branch of
every screen, carefully, with a harness that proved what changed. A review pass
would have found them. A review pass would have cost a day and no lines.

And here is the thing about the editing win: it bought a better experience for
the person editing sentences and sold a worse one to the person reading code.
Those are the same person. On a two\-person project they are the same person on
the same afternoon.

Which is the argument I did not have until I had done it twice:

> The text intermingled with the code explains a lot. The text puts the code in
> context. The code puts the text in context.

A template that says *"The faucet gives 0.6 DEMO and 0.05 SOL, once per
wallet"* next to the expression that produces `0.6` is two sources of truth
checking each other. Read the sentence and you know what the expression is for.
Read the expression and you know whether the sentence is still true. Separate
them and both halves get weaker: the sentence loses the values that make it
concrete, and the code loses the only plain\-language statement of its purpose.

That is not a tooling problem and no amount of convention fixes it. It is what
traded.

## The emblem

The best summary of the whole exercise is a bug I introduced and did not notice
for two days.

When a clone has not run the content build, the site is supposed to serve a 503
carrying that thirteen\-line template: *nothing is built yet, here is what to
type.* On the old code it renders in 364 bytes with no build at all.

On the new code it throws — because its sentences live in the build output that
is missing. So does the page shell, so nothing renders anywhere. The exception
message is perfectly correct (*"no copy for 'not\_built.lede' in content/ui/;
run bin/build\-content"*) and it goes to a log, not to the person who needed it.

**The page whose entire job is to say "run the build" now requires the build.**
The screen that exists for the case where the machinery is missing was made to
depend on the machinery. If I were arguing for the refactor I would call that a
bug and fix it in ten minutes, which it is, and I could. As a description of
what I had done it is hard to improve on.

## What I would keep

One screen converted looked like a win, and that was the trap. The meter screen
alone was a good trade: four hundred and eighty\-nine words, three copies of one
heading collapsed into one key, a template that got meaningfully shorter. If I
had stopped there I would still think this was a good idea.

The cost does not appear until the twentieth screen, because the cost is not
per\-screen. It is the moment you stop being able to read the application. That
is an emergent property and you cannot sample it.

So: **the only justification for separating the text from the code is the one
that forces it — human language translation.** If a second locale is coming,
the words have to leave, and every cost above is simply the price of admission.
If it is not, you are paying the price for nothing but a tidier place to type.
A tidier place to type is not worth an application you cannot read.

I am keeping the four bug fixes. The rest goes back.
