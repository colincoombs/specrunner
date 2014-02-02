# Specrunner

BDD for Arduino-like projects

This program is very much like the 'mocha' test runner.
The big difference is that it is used to specify code running on
an Arduino board, in terms of the interaction between that board
and the attached hardware.

There is nothing inherently Arduino-specific about the design of
this program,
I am sure that it could easily be adapted for use with any other
board with a little microcontroller chip on it.

But ... all _I_ have to develop it with is an Arduino (Duemilanove,
to be precise), so that's what I am targeting for now.

The program is implemented in CoffeeScript, because I have plans to
integrate it with other node.js packages, but that's another story.

## Current status

version 0.0.1: 
  all the basic functionality seems to be present, and it seems to work!
