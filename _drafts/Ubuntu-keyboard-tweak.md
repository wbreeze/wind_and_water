---
layout: post
title: Ubuntu keyboard tweak
date: 2023-10-16
lang: en
categories: XKB Linux Ubuntu Keyboard Computing
excerpt: I make XKB tweaks in Ubuntu Linux to get my keyboard configured
  the way I like.
---
I bought a very basic, hundred dollar notebook that runs on twelve volts with
maximum two amps of power draw. It's an Evolve III Maestro. It is a computer
sometimes issued to school children.

![Evolve III Keyboard]({{ '/assets/images/2023/Keyboard.jpg' | relative_url }})

It came with Windows 10 educational edition. Windows was invasive and
annoying to the extreme.  Every Microsquishy application including the
operating system itself insisted on an account (and internet connection) to use
it. This is most likely so that Microsquishy can be assured that they were paid
for; but, I doubt they could resist going further. I hate to think of all of
those young minds submitting themselves to Microsquishy surveillance. That's
our world now.

I installed [Kubuntu Linux][kubuntu] using the lightweight install.  It is
working great.  I fantasized about being the teacher handing-out thumb-drives
flashed with Kubuntu install images to my students and instructing them how to
install it.  The only real headache was getting the keyboard mapped the way I
need it. (My special case.) It took me a couple of days to work that out.

[kubuntu]: https://kubuntu.org/

## Modding the Keyboard
The system of keyboard mapping in Linux distributions these days is something
called, "The X keyboard extension," or "[xkb][xkb]" for short.  Ex Kay Bee.
**X** **K**ey**B**oard.  It's pretty complicated.  There are resouces for
understanding it in the [xOrg wiki for XKB][wiki].

[xkb]: https://en.wikipedia.org/wiki/X_keyboard_extension
[wiki]: https://www.x.org/wiki/XKB/

The desktop GUI app that came installed with the Kubuntu,
for selecting and managing keyboard mappings worked well for me.
I found the keyboard mapping that most resembled what I want and installed
it with no problem, quickly and easily.

The hard part was tweaking it. Help came from an [answer on SuperUser
StackExchange][suex].  I also read some of the XKB documentation, including an
[xkb overview document][xov] written "third party", apart from the development
code base.  There's a [formal standard specification][xkbp] that I didn't dig
into.

[suex]: https://superuser.com/a/1168603
[xov]: https://www.charvolant.org/doug/xkb/html/xkb.html
[xkbp]: https://www.x.org/releases/current/doc/libX11/XKB/xkblib.html

It took me a couple or few days to come up with this. Here's the tweak:

I put the following in the file, `~/.xkb/symbols/xkb_dcl_sym`

```
default partial alphanumeric_keys modifier_keys
xkb_symbols "dcl_syms" {
    //Have Caps Lock do the ISO shift level three
    key <CAPS> { [     ISO_Level3_Shift      ]   };
    //Fix the Q key so that single and double quote are the normal symbols there
    key <AD01> { [     apostrophe,   quotedbl, dead_acute,  dead_diaeresis  ]   };
    //Fix the ~ key so that back tick and tilde are the normal symbols there
    key <TLDE> { [     grave,   asciitilde, dead_grave,  dead_tilde  ]   };
};
```

The X utility, `xev` run as, `xev | sed -ne '/^KeyPress/,/^$/p'`
gave me very useful clues about what the keyboard keys were doing and
what to write in the symbol file.

I ran `setxkbmap -print >.xkb/xkb_dcl` to get the current specification
into the file, `~/.xkb/xkb_dcl`.
I then edited that file to add my symbol tweaks.
The content of the file is as follows.
Note "`+xkb_dcl_sym(dcl_syms)`" in the `xkb_symbols` include.
That is what I added.

```
xkb_keymap {
	xkb_keycodes  { include "evdev+aliases(qwerty)"	};
	xkb_types     { include "complete"	};
	xkb_compat    { include "complete"	};
	xkb_symbols   { include "pc+us(dvorak-intl)+us:2+inet(evdev)+xkb_dcl_sym(dcl_syms)"	};
	xkb_geometry  { include "pc(pc101)"	};
};
```

In order to install it, I run `xkbcomp -I$HOME/.xkb $HOME/.xkb/xkb_dcl $DISPLAY`.
That puts a bunch of warnings on the console; however, it works. The Caps Lock
and the qwerty keys labeled 'Q' and '~' now do what I want them to.
Note the comments in the above listing of `~/.xkb/symbols/xkb_dcl_sym`.

The `ISO_Level3_Shift` gives me the [acute accent][acute] over the vowel
letters (á, é, í, ó, ú) and the [tilde accent][tilde] over the 'n' (ñ) needed
to type in Spanish.  The Caps Lock is about the most useless key on the
keyboard.  People frequently remap this key to something more useful.  I've
made it the `ISO_Level3_Shift`.

[acute]: https://en.wikipedia.org/wiki/Acute_accent
[tilde]: https://en.wikipedia.org/wiki/Tilde

I put the command in a file, `$HOME/.xprofile` so that X makes the mapping
every time I log in.  By some magic, fortunately, I can still switch between
qwerty and Dvorak layouts without losing the key mappings installed over the
Dvorak layout.

## Maestro review
I'm hoping the Evolve III Maestro computer will serve for editing the blogs I
write-- this one and [Brisa.uy][brisa]. I edit the blogs with a text editor (vi)
and use a Ruby interpreter running [Jekyll][jekyll] to generate the pages. That
it will run from the twelve volt power supply on my boat and allow me to
write is all I expect from it.

The computer has a touchpad that responds strangely-- with delays or
little jigs.  It's difficult to point or scroll accurately with it.
I found an inexpensive optical mouse to use with it.

The keyboard is a little cramped for my adult hands. Sometimes I press a key
when typing and no character comes out.  That's getting better as I use it
more.  It's perhaps that I don't get the key depressed fully enough, with
enough force. I'm used to something lighter.

My MacBook pro no longer runs (for long) on the battery. It draws a pretty
high amperage off of USB. For the boat, I've ordered and will install USB
outlets that draw-off the twelve volt supply and deliver the USB voltage at
four amps.  That is higher current/load/amps than delivered by the currently
installed outlets. Either way, I have this low-demand device, now, to
write and correspond with.

[brisa]: https://brisa.uy/
[jekyll]: http://jekyllrb.com/

