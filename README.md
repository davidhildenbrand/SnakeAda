# SnakeAda
A very simple and inefficient version of Snake written in Ada / SPARK

## Description
This is a very simple and inefficient implementation of the famous Snake
game in Ada / SPARK. The goal is to control the Snake, eating as much food
as possible without crashing into the wall or biting itself into the tail.

This program was created in the context of a programming assignment during
the course "Real-Time Programming Languages" at the TUM (Technical University
Munich) - http://www.rcs.ei.tum.de/en/courses/lectures/rtpl/

The core game logic is written in SPARK, with some properties/contracts
added and verified. As some part of the assignment was to make use of
a selected feature set of Ada / SPARK, code quality might not be optimal :)

## Compiling
Please download and install GPS from https://www.adacore.com/download/more to
compile to program (optionally also SPARK to verify the code).

For graphical output, GtkAda is used. So be sure to download and install
it from https://www.adacore.com/download/more, following the details in
README.txt.

For Linux, please use "snake.gpr". For Windows, please use "snake_windows.gpr.

In order to prove with SPARK, 'with "gtkada"' has to be changed to reference
the absolute path of "gtkada.gpr" in snake.gpr. E.g. on Linux this usually
has to be
	with "/opt/gnat/lib/gnat/gtkada.gpr";

See "snake_gnatprove.gpr" for an example.

Otherwise SPARK won't be able to locate it and report an error when
trying to run gnatprove.

## Starting Snake
Starting Snake out of GPS works just fine. However, starting it directly from
command line usually does not work reliably, as the GtkAda setup (e.g.
environment variables) is messed up. Then, it can happen that the game output
will not work reliably - esp. showing up with quite some delay. This is
usually indicated e.g. by "GdkPixbuf-WARNING".

## Controlling Snake

The game will start immediately after starting the program. To restart, press
"r". To quit, press "q". The Snake can be controlled with the arrows on the
keyboard or alternatively with a-w-s-d.

## Author
David Hildenbrand <david.hildenbrand@gmail.com>
