---
layout: post
title: Test with Emoji
date: 2019-08-29
categories: software testing
excerpt: Emoji. They're everywhere these days. If your application takes user
  input, guess what? You're going to get them.
---

![Heart Cat Emoji]({% link /assets/images/heart_cat_emoji.png %})

Emoji. They're everywhere these days. If your application takes user input,
guess what? You're going to get them. They come in text like this, 😻 which
characters were first defined in the Unicode standard version 6.0.
According to its [Unicode table
entry](https://unicode-table.com/en/1F63B/)
it's value is `U+1F63B`. It may be coded
in an HTML document as `&#128571;`.

You're likely familiar with Unicode
text encodings. In the popular encoding,
[UTF-8](https://tools.ietf.org/html/rfc3629), the emoji requires four
bytes. Their values are `F0 9F 98 BB`.

UTF-8 was developed by no less than Ken Thompson and Rob Pike, both
alumni of the famous Bell Labs, where so many of the foundations for computing
were laid. Thompson wrote the first Unix and collaborated on the development
of the C programming language. The two are part of a trio at Google who
developed the programming language, Go.

UTF-8 is the most popular Unicode encoding scheme on the planet
. (Who knows about elsewhere?) By a large
margin. As in, almost everybody uses it. You use it. I'll bet.

## mySQL

If you use mySQL, also wildly popular but losing ground to Postgres, so I hear,
you might have been seduced by the character encoding, 'utf8' for use in text
and string valued columns of your data tables. Lovely. Marvelous. UTF-8
everywhere!

If you were, as I was, you might have missed a little tiny detail.
The `utf8` character encoding in mySQL uses (up to) three bytes.
That's a three. The cat emoji you try to put into the string
column of a record in your table will whisper to you a sweet nothing like,

    # Mysql2::Error:
    #   Incorrect string value: '\xF0\x9F\x98\xBBysto...'

(Not exactly that, but something like it. You get the idea.) What's up?
Well, we just tried to stuff four bytes of perfectly legitimate UTF-8 encoded
cat into a three byte crate. Meow 😾. Cat scratch fever.

Checking-in with the [mySQL reference manual 5.7, section
10.10](https://dev.mysql.com/doc/refman/5.7/en/charset-charsets.html),
or opening a mySQL command prompt and typing, `SHOW CHARACTER SET;`,
scanning the list of available sets, we find that little three in the
`Maxlen` column for `utf8`. Oh the woe.

What we have to do to properly support UTF-8 content in mySQL is apply
the character encoding `utf8mb4`. It has the same description as `utf8`,
"UTF-8 Unicode" only happily in the `Maxlen` column, a four.

## Testing

The other day (well, yesterday), while updating some tests for
[iaccdb](https://github.com/wbreeze/iaccdb) I picked-up a mySQL error
like the one above. It was because the table, by some accident of inattention,
had picked-up a `latin1` character encoding. The story is the same for
`utf8` encodings, although slightly less drastic. The other tables were
encoded `utf8`.

The error had never occurred before because all of my test data was pretty
much ASCII. UTF-8 encoded, but not straying from the easy for everybody
ASCII portion of the set.

What had changed was that I had entertained myself by fixing up some of
the test data using
[Faker::Space.meteorite](https://github.com/faker-ruby/faker/blob/020effa0d37e344a60819a4f9dd78a9b01b1c56a/lib/locales/en/space.yml)
(and Faker::Space.nasa_space_craft).
That data set has a couple of entries with UTF-8 two-byte characters, including
for example, "Sołtmany" and "Příbram". These aren't going to shoehorn into
`latin1`, not any day.

First, I thought, "You idiot, why did you go getting all fancy with the
test data. Leave well enough alone." For a moment, I felt tempted to revert
to a tamer data set for testing. But only for a moment.

What had I done? I'd uncovered a bug, albeit accidentally, by making my
tests fancier.
That is, assuming I want the application to support values like, "Łowicz",
or emoji like 🛩️.  It should.  The only right thing to do was to fix it.

## Repairing the encoding

Skipping back to the mySQL documentation, there's lots of great information
about character encodings, and ways to change them, including [this
section](https://dev.mysql.com/doc/refman/5.7/en/alter-table.html#alter-table-character-set)
about how to convert a table.

    ALTER TABLE tbl_name CONVERT TO CHARACTER SET charset_name;

The key here is that the statement doesn't merely set a new default for
new columns, but converts all existing text and string columns to the
changed encoding. There are a few caveats about this.

If you already have a lot of data in your live, production database, this is
going to take some time. It's going to be down time, because at least writes to
the table will be locked. In my case, the production database has fewer than
two thousand records in the affected tables. If your tables have millions of
records, you're going to get creative.

If a column has `latin1` encoding but actually contains `utf8` encoded
data, which is possible but not probable, the `CONVERT` operation will
double-up the multibyte characters in strange ways. You have to verify by,
for example,

    mysql> select distinct make, hex(make) from make_models \
      where make is not null and 0 < length(make) limit 12;
    +------------+----------------------+
    | make       | hex(make)            |
    +------------+----------------------+
    | 107        | 313037               |
    | 336        | 333336               |
    | 8K         | 384B                 |
    | 8K  CAB    | 384B2020434142       |
    | 8KCAB      | 384B434142           |
    | ACA        | 414341               |
    | ACA8KCAB   | 414341384B434142     |
    | Acro       | 4163726F             |
    | Acro One   | 4163726F204F6E65     |
    | Acro Sport | 4163726F2053706F7274 |
    | Acrosport  | 4163726F73706F7274   |
    | Aeronca    | 4165726F6E6361       |
    +------------+----------------------+

and then compare with the encoded values, in Ruby for example,


    irb 0> "Aeronca".encode('ISO-8859-1').bytes.collect { |b|
    irb 1*   sprintf("%02x", b) }.join
    => "4165726f6e6361"
    irb 0> "Aeronca".encode('UTF-8').bytes.collect { |b|
    irb 1*   sprintf("%02x", b) }.join
    => "4165726f6e6361"
    irb 0> "Aéróncá".encode('ISO-8859-1').bytes.collect { |b|
    irb 1*   sprintf("%02x", b) }.join
    => "41e972f36e63e1"
    irb 0> "Aéróncá".encode('UTF-8').bytes.collect { |b|
    irb 1*   sprintf("%02x", b) }.join
    => "41c3a972c3b36e63c3a1"

You might want to insert a multi-byte value, like `Aéróncá`, into the table
if, as in the example, there are none.

### Collation

It's necessary to ensure that the collation used by the new character
encoding is compatible with the instance of mySQL running your production
databases. In my instance, my development machine produced a collation
of `utf8mb4_0900_ai_ci`. This collation was not present on Travis
(who caught it), running mySQL 5.7 on Ubuntu Xenial (16.04).

The available collations may be determined by invoking
`SHOW COLLATION;` at a mySQL prompt. In this case, there are a number
of locale specific collations available, and (at least) two general ones.
According to the mySQL documentation section [10.1.1, Unicode Character
Sets](https://dev.mysql.com/doc/refman/5.7/en/charset-unicode-sets.html),
the `utf8mb4_general_ci` collation will be fastest and work with single
characters. The `utf8mb4_unicode_ci` collation will properly handle
combined characters for most languages, and the `utf8_unicode_520_ci`
collation correctly implements Unicode Collation Algorithm 5.2.0.

In order to get a collation that's bound to work, I had to update the
`ALTER TABLE` statements as follows:

    ALTER TABLE `airplanes` CONVERT TO CHARACTER SET `utf8mb4` \
      COLLATE `utf8mb4_unicode_ci`;

### Column and key lengths

Other than the amount of time required in locking-down a table and
converting it, there will be space changes. Depending on how many
records you have in your tables, they could be significant.
Changes in column lengths have other implications as well.

The lengths of text or string columns, measured in bytes, is going to
increase as much as four times. If your current character encoding is a
one byte encoding, it will be an increase of four times. If your current
encoding is 'utf8', which requires three bytes per character,
the multiplier will be four-thirds (4/3).

One of the impacts might be on your keys, as happened to me:

    ActiveRecord::StatementInvalid: Mysql2::Error: \
      Specified key was too long; max key length is 767 bytes: \
      ALTER TABLE `make_models` CONVERT TO CHARACTER SET `utf8mb4` \
      COLLATE `utf8mb4_unicode_ci`;

To repair it, I had to truncate the columns involved in the key, by fixing
a shorter length. This didn't truncate any data. The lengths to begin with
were too large, much larger than required for any of the expected data values.
You could say this was another error, not conservatively fixing the column
length to begin with.

## Conclusion

The moral of the story is, if you're going to support UTF-8 (and you are),
make sure you have some UTF-8 encoded, four byte characters in your test data.
In effect, use some emoji. Give it a little ❤️.
