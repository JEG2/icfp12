# -*- coding: utf-8 -*-

module LambdaDash
  class Robot
    def initialize(map)
      @aborted           = false
      @on_lift           = false
      @dead              = false
      @map               = map
      @lambdas_collected = 0
      @moves             = ""
      locate_self
    end

    attr_reader :map, :x, :y, :lambdas_collected, :moves

    def move(ascii)
      ascii.chars.each do |move|
        case move
        when "U" then try_move(x,     y + 1)
        when "D" then try_move(x,     y - 1)
        when "L" then try_move(x - 1, y,     x - 2)
        when "R" then try_move(x + 1, y,     x + 2)
        when "A" then abort
        end
        @moves << move
      end
    end

    def die
      @dead = true
    end

    def game_over?
      @aborted or @on_lift or @dead or @moves.size >= map.max_moves
    end

    def score
      score = 25 * @lambdas_collected - @moves.size
      if @aborted
        score + 25 * @lambdas_collected
      elsif @on_lift
        score + 50 * @lambdas_collected
      else
        score
      end
    end

    def to_s
      " turn: #{moves.size}/#{map.max_moves}\n" +
      "score: #{score}\n"                       +
      "moves: #{@moves.size > 10 ? "…#{moves[-10..-1]}" : moves}\n"
    end

    private

    def locate_self
      robot = @map.find(&:robot?)
      @x    = robot.x
      @y    = robot.y
    end

    def move_to(to_x, to_y)
      map[to_x, to_y] = "R"
      map[x,    y]    = " "
      @x, @y          = to_x, to_y
    end

    def try_move(to_x, to_y, rock_pushed = nil)
      unless map[to_x, to_y].impassable?
        if map[to_x, to_y].rock? and
           rock_pushed.to_i > 0  and
           map[rock_pushed, to_y].empty?
          map[rock_pushed, to_y] = "*"
          move_to(to_x, to_y)
        elsif not map[to_x, to_y].rock?
          if map[to_x, to_y].lambda?
            @lambdas_collected += 1
          elsif map[to_x, to_y].open_lift?
            @on_lift = true
          end
          move_to(to_x, to_y)
        end
      end
    end

    def abort
      @aborted = true
    end
  end
end