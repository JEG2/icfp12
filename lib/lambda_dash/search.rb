module LambdaDash
  class Search
    def initialize(robot, algorithm)
      @map       = robot.map
      @robot     = robot
      @algorithm = algorithm

      raise "Unknown algorithm" unless respond_to? @algorithm
    end

    attr_reader :map, :robot, :algorithm

    def find_moves
      reader, writer = IO.pipe
      pid            = fork do
        reader.close
        @time_up = false
        trap(:INT) do
          @time_up = true
        end
        writer.print send(algorithm)
      end
      writer.close
      thread = Thread.new do
        begin
          sleep 150
          Process.kill(:INT, pid)
          sleep 10
          Process.kill(:KILL, pid)
        rescue
          # do nothing:  our process is gone
        end
      end
      reader.read
    ensure
      thread.kill if thread
    end

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

    # RRUDRRULUURWLLLDDLDL
    def pruned_search
      best  = robot.dup
      queue = [best]
      @seen = {best.map.to_s => best.score}
      while not time_up? and (current = queue.shift)
        added_moves = false
        current.legal_moves.each do |move|
          new_move = current.dup
          new_move.move(move)
          new_move.map.update(new_move) unless new_move.game_over?
          map_str = new_move.map.to_s
          unless prune?(best, new_move, map_str, new_move.score)
            if new_move.score > best.score
              best = new_move
            end
            unless new_move.game_over?
              added_moves = true
              queue << new_move
            end
          end
        end
        queue = prioritize_moves(queue) if added_moves
      end
      best.moves
    end

    private

    def time_up?
      @time_up
    end

    def prune?(best, robot, map_str, score)
      if Scorer.new(robot.map, robot).james_algorithm >= best.score and
         (not @seen.include?(map_str) or score > @seen[map_str])
        @seen[map_str] = score unless robot.aborted?
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
