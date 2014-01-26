require 'rubygems'
require 'gosu'

WIN_WIDTH     = 800
WIN_HEIGHT    = 600
BALL_WIDTH    = 20
BALL_HEIGHT   = 20
BALL_START_X  = rand(BALL_WIDTH..WIN_WIDTH - BALL_WIDTH)
BALL_START_Y  = rand(BALL_HEIGHT..WIN_HEIGHT - BALL_HEIGHT)
X_VELOCITY    = 4
Y_VELOCITY    = 4
MAX_VELOCITY  = 30
MIN_VELOCITY  = 1
PADDLE_WIDTH  = 20
PADDLE_HEIGHT = 60
PADDLE_Y_STEP = 6
PADDLE_INSET  = 30  # distance from left/right window edge to paddle's edge

class Ball
  attr_reader :x, :y, :w, :h
  attr_accessor :vx, :vy

  def initialize(the_window)
    @x = BALL_START_X
    @y = BALL_START_Y
    @vx = X_VELOCITY
    @vy = Y_VELOCITY
    @w = BALL_WIDTH
    @h = BALL_HEIGHT
    @image = Gosu::Image.new(the_window, './assets/ball.png', false)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def move
    @x = @x + @vx
    @y = @y + @vy

    # Check for collision with window borders
    @vx = -@vx if @x <= 0 || @x >= WIN_WIDTH - @w
    @vy = -@vy if @y <= 0 || @y >= WIN_HEIGHT - @h
  end

  def reverse
    @vx = -@vx
  end
end

# Class for the left and right paddles.
class Paddle
  attr_reader :x, :y, :w, :h

  def initialize(the_window, xpos)
    @x = xpos
    # here we center the paddle vertically
    @y = (WIN_HEIGHT / 2) - (PADDLE_HEIGHT / 2)
    @w = PADDLE_WIDTH
    @h = PADDLE_HEIGHT
    @image = Gosu::Image.new(the_window, './assets/paddle.png', false)
  end

  def move_up
    @y = @y - PADDLE_Y_STEP if @y > 0
  end

  def move_down
    @y = @y + PADDLE_Y_STEP if @y < WIN_HEIGHT - PADDLE_HEIGHT
  end

  def draw
    @image.draw(@x, @y, 1)
  end
end

# Class to keep the score for each player.
class Score
  def initialize(the_window, xpos)
    @score = 0
    @can_change = true
    @x = xpos
    @y = 20
    @font = Gosu::Font.new(the_window, 'System', 30)
  end

  def draw
    @font.draw("#{@score}", @x, @y, 1)
  end

  # Note that the @can_change state is a toggle; this is used to prevent
  # score increases when the ball gets "stuck" behind a paddle
  def increase
    @score = @score + 1
    @can_change = false
  end

  def can_increase?
    @can_change
  end

  def turn_on_scoring
    @can_change = true
  end
end

# Class for the main game window.
class GameWindow < Gosu::Window
  def initialize
    super WIN_WIDTH, WIN_HEIGHT, false
    self.caption = 'Paddle Game'
    @ball = Ball.new(self)
    @left_paddle = Paddle.new(self, PADDLE_INSET)
    @right_paddle = Paddle.new(self, WIN_WIDTH - PADDLE_WIDTH - PADDLE_INSET)
    @left_score = Score.new(self, 20)
    @right_score = Score.new(self, 760)
  end

  # Method for collision detection (i.e., if the ball and one of the
  # paddles are touching).
  # To keep this simple, assume that both objects are rectangular
  # in shape; even though the ball is a circle, we can treat it as a square.
  #
  # TODO: Add code to check for collison between a circle and a rectangle,
  # which will require a bit more sophisticated mathematics...
  def colliding?(obj1, obj2)
    obj1.x > obj2.x - obj1.w &&
    obj1.x < obj2.x + obj2.w &&
    obj1.y > obj2.y - obj1.h &&
    obj1.y < obj2.y + obj2.h
  end

  # Gosu requires the 'update' and 'draw' methods in your main
  # Gosu::Window inherited window class.
  # They are repeatedly called one after the other until program termination.
  # (i.e., update, draw, update, draw, update, draw, etc....)
  def update
    @ball.move

    @left_paddle.move_up if button_down?(Gosu::KbW)
    @left_paddle.move_down if button_down?(Gosu::KbS)
    @right_paddle.move_up if button_down?(Gosu::KbO)
    @right_paddle.move_down if button_down?(Gosu::KbL)
    @ball.reverse if colliding?(@ball, @left_paddle)
    @ball.reverse if colliding?(@ball, @right_paddle)

    if button_down?(Gosu::Kb0)
      if @ball.vx.abs < MAX_VELOCITY
        if @ball.vx < 0
          @ball.vx = @ball.vx - 1
        else
          @ball.vx = @ball.vx + 1
        end
      end

      if @ball.vy.abs < MAX_VELOCITY
        if @ball.vy < 0
          @ball.vy = @ball.vy - 1
        else
          @ball.vy = @ball.vy + 1
        end
      end
    end

    if button_down?(Gosu::Kb1)
      if @ball.vx.abs > MIN_VELOCITY
        if @ball.vx >= 0
          @ball.vx = @ball.vx - 1
        else
          @ball.vx = @ball.vx + 1
        end
      end

      if @ball.vy.abs > MIN_VELOCITY
        if @ball.vy >= 0
          @ball.vy = @ball.vy - 1
        else
          @ball.vy = @ball.vy + 1
        end
      end
    end

    # Check for scoring condition
    @right_score.increase if @ball.x <= 0 && @right_score.can_increase?
    @left_score.increase if @ball.x >= WIN_WIDTH - BALL_WIDTH &&
      @left_score.can_increase?

    # Re-enable scoring when the ball passes through the middle area of the
    # window.
    # It is turned off after each score point to prevent multiple
    # scores due to the ball sometimes getting "stuck" on or behind the paddle.
    if (@ball.x > (WIN_WIDTH / 2) - 60) && (@ball.x < (WIN_WIDTH / 2) + 60)
      @left_score.turn_on_scoring
      @right_score.turn_on_scoring
    end

    # Debugging info - remove after testing.
    # puts "vx = #{@ball.vx}\t\tvy = #{@ball.vy}"
  end

  # Gosu requires the 'update' and 'draw' methods.
  # They are repeatedly called one after the other
  # (i.e., update, draw, update, draw, update, draw, etc....)
  def draw
    @ball.draw
    @left_paddle.draw
    @right_paddle.draw
    @left_score.draw
    @right_score.draw
  end
end

window = GameWindow.new
window.show
