module LambdaDash
  class Search
    def initialize(robot)
      @map     = robot.map
      @robot   = robot
      @time_up = false
    end

    attr_reader :map, :robot
    attr_writer :time_up

    def fast_test
      "A"
    end

    def slow_test
      loop do
        sleep 0.1
        break if time_up?
      end
      "A"
    end

    def kill_me_test
      loop do
        sleep
      end
    end

    def pruned_search
      best  = robot.dup
      queue = [best]
      @seen = {best.map.hash_key => best.score}
      while not time_up? and (current = queue.shift)
        added_moves = false
        current.legal_moves.each do |move|
          new_move = current.dup
          new_move.move(move)
          new_move.map.update(new_move) unless new_move.game_over?
          unless prune?(best, new_move)
            if new_move.score > best.score
              best = new_move
            end
            unless new_move.game_over?
              added_moves = true
              queue << new_move
            end
          end
          break if time_up?
        end
        queue = prioritize_moves(queue) if added_moves
      end
      best.moves
    end

    private

    def time_up?
      @time_up
    end

    def prune?(best, robot)
      if Scorer.new(robot.map, robot).james_algorithm >= best.score and
         ( not @seen.include?(robot.map.hash_key)                   or
           robot.score > @seen[robot.map.hash_key] )
        @seen[robot.map.hash_key] = robot.score unless robot.aborted?
        false
      else
        true
      end
    end

    def prioritize_moves(queue)
      queue.sort_by { |robot| -robot.score }
    end
  end
end
