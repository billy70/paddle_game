paddle_game
===========

A Ruby version of the classic Pong video game.

This is my first program written in Ruby, and my first project checked into git.

The program is a clone of the classic Pong game. The object of the game is to
prevent the ball from hitting your side of the screen; if it does, your
opponent will score a point. Currently, there is no score limit; the game
will continue to run and score until terminated.

File list:

paddle_game.rb - the paddle game Ruby source code file
README - this file
assets/ball.pxm - ball image in Pixlemator native file format
assets/ball.png - ball image used by paddle_game.rb
assets/paddle.pxm - paddle image in Pixelmator native file format
assets/paddle.png - paddle image used by paddle_game.rb

NOTE: The .gitattributes files specifies that the 'exiftool' is to be used for
doing diffs on the *.png files, so if you do not have this installed, it may
fail when trying to diff PNG files.
