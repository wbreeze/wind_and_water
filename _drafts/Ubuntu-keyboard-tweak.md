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
maximum two amps of power draw. It's an Evolve III Maestro. The computer they
give to school children.

It came with Windows 10 educational edition, but screw that. Very annoying.
Every Microsquishy application including the operating system itself insists
on an account to use it. This is most likely so that Microsquishy can be assured that they
were paid; but, I doubt they could resist going further.

I installed [Kubuntu Linux][kubuntu] using the lightweight install.
It is working great. The only real headache was getting the keyboard mapped
the way I need it. It took me a couple of days to work that out.

## XKB keyboard tweak
The system of keyboard mapping in Linux distributions these days is
something called, "The X keyboard extension," or "[xkb][xkb]" for short.
Ex Kay Bee. *X* *K*ey*B*oard.
It's pretty complicated.
There are resouces for understanding it in the [xOrg wiki for XKB][wiki].

[xkb]: https://en.wikipedia.org/wiki/X_keyboard_extension
[wiki]: https://www.x.org/wiki/XKB/

The desktop GUI app that came installed with the Kubuntu,
for selecting and managing keyboard mappings worked well for me.
I found the keyboard mapping that most resembled what I want and installed
it with no problem, quickly and easily.

The hard part was tweaking it. Help came from an [answer on SuperUser
StackExchange][suex].  Another [answer on Unix StackExchange][lex] gives a more
involved solution.  I also read some of the XKB documentation, including an
[xkb overview document][xov] written "third party", apart from the development
code base.  There's a [formal standard specification][xkbp] that I didn't dig
into.

[lex]: https://unix.stackexchange.com/a/215062
[suex]: https://superuser.com/a/1168603
[xov]: https://www.charvolant.org/doug/xkb/html/xkb.html
[xkbp]: https://www.x.org/releases/current/doc/libX11/XKB/xkblib.html

It took me a couple or few days to come up with this. Here's the tweak:

I put the following in `~/.xkb/symbols/xkb_dcl_sym`

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

In order to install it, I run `xkbcomp -I$HOME/.xkb .xkb/xkb_dcl $DISPLAY`.
That puts a bunch of warnings on the console; however, it works. The caps lock
and the qwerty key labeled 'Q' now do what I want them to. What is that?
Note the comments in the above listing of `~/.xkb/symbols/xkb_dcl_sym`.

The ISO_Level3_Shift gives me the [acute accent][acute] over the vowel letters
and the [tilde accent][tilde] over the 'n' needed to type in Spanish.
The Caps Lock is about the most useless key on the keyboard.
People frequently remap this key to something more useful.
I've made it the ISO_Level3_Shift.

[acute]: https://en.wikipedia.org/wiki/Acute_accent
[tilde]: https://en.wikipedia.org/wiki/Tilde

The X utility, `xev` run as, `xev | sed -ne '/^KeyPress/,/^$/p'`
gave me very useful clues about what the keyboard keys were doing and
what to write in the symbol file.

## Maestro review
The computer itself has a touchpad that responds strangely-- with delays or little jigs.
It's difficult to point or scroll accurately with it. The keyboard is a little cramped
for my adult hands. Sometimes I press a key when typing and no character comes out.
That's getting better as I use it more. It's perhaps that I don't get the key
depressed fully enough, with enough force. I'm used to something lighter.

My MacBook pro no longer runs (for long) on the battery. It draws a pretty
high amperage off of USB. I've ordered and will install USB outlets
that draw-off the twelve volt supply and deliver the USB voltage at four amps.
That is higher current/load/amps than delivered by the currently installed outlets.

I'm hoping the Evolve III Maestro computer will serve for editing the blogs I
write. This one and [Brisa.uy][brisa]. I edit the blogs with a text editor (vi)
and Ruby interpreter. I'm hoping that the computer will run from the twelve
volt power supply on my boat, with little power draw. That's all I expect from
it.

