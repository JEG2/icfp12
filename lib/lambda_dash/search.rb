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

    private

    def time_up?
      @time_up
    end
  end
end
