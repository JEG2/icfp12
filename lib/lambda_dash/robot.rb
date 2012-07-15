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
      @turns_underwater  = 0
      @razors            = map.metadata[:razors]
      @score             = nil
      locate_self
    end

    def initialize_copy(_)
      super
      @map   = @map.dup
      @moves = @moves.dup
    end

    attr_reader :map, :x, :y, :moves,
                :lambdas_collected, :turns_underwater, :razors

    def move(ascii)
      ascii.chars.each do |move|
        case move
        when "U" then try_move(x,     y + 1)
        when "D" then try_move(x,     y - 1)
        when "L" then try_move(x - 1, y,     x - 2)
        when "R" then try_move(x + 1, y,     x + 2)
        when "A" then abort
        when "S" then slash_beards
        end
        @moves << move
      end
      clear_score
      map.clear_hash_key
    end

    def die
      @dead = true
    end

    def aborted?
      @aborted
    end

    def game_over?
      @aborted or @on_lift or @dead or move_count >= map.max_moves
    end

    def check_water_level(level, waterproof)
      if y <= level
        @turns_underwater += 1
        die if @turns_underwater >= waterproof
      else
        @turns_underwater = 0
      end
    end

    def clear_score
      @score = nil
    end

    def score
      return @score if @score
      @score = 25 * @lambdas_collected - move_count
      if @aborted
        @score += 25 * @lambdas_collected
      elsif @on_lift
        @score += 50 * @lambdas_collected
      else
        @score
      end
    end

    def move_count
      moves.sub(/A\z/, "").size
    end

    def legal_moves
      return [ ] if game_over?
      moves  = %w[W A]
      moves << "U" if y < map.m                     and
                      not map[x, y + 1].impassable? and
                      not map[x, y + 1].rock?
      moves << "D" if y > 1                         and
                      not map[x, y - 1].impassable? and
                      not map[x, y - 1].rock?
      moves << "R" if ( x < map.n                       and
                        not map[x + 1, y].impassable? ) or
                      ( x < map.n - 1                   and
                        map[x + 1, y].rock?             and
                        map[x + 2, y].empty? )
      moves << "L" if ( x > 1                           and
                        not map[x - 1, y].impassable? ) or
                      ( x > 2                           and
                        map[x - 1, y].rock?             and
                        map[x - 2, y].empty? )
      moves << "S" if @razors > 0 and map.neighbors(x, y).any?(&:beard?)
      moves
    end

    def to_s
      " turn: #{move_count}/#{map.max_moves}\n" +
      "score: #{score}\n"                       +
      "moves: #{move_count > 10 ? "…#{moves[-10..-1]}" : moves}\n"
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
        if map[to_x, to_y].trampoline?
          target = map.trampolines[map[to_x, to_y]]
          move_to(target.x, target.y)
          map.trampolines.each do |trampoline, other_target|
            if target == other_target
              map[trampoline.x, trampoline.y] = " "
            end
          end
        elsif map[to_x, to_y].rock? and
           rock_pushed.to_i > 0  and
           map[rock_pushed, to_y].empty?
          map[rock_pushed, to_y] = "*"
          move_to(to_x, to_y)
        elsif not map[to_x, to_y].rock?
          if map[to_x, to_y].lambda?
            @lambdas_collected += 1
            map.lambdas.delete(map[to_x, to_y])
          elsif map[to_x, to_y].open_lift?
            @on_lift = true
          elsif map[to_x, to_y].razor?
            @razors += 1
          end
          move_to(to_x, to_y)
        end
      end
    end

    def abort
      @aborted = true
    end

    def slash_beards
      if @razors > 0
        map.neighbors(x, y).each do |neighbor|
          map[neighbor.x, neighbor.y] = " " if neighbor.beard?
        end
        @razors -= 1
      end
    end
  end
end