module LambdaDash
  module Simulator
    ROOT_DIR = File.expand_path("../..", File.dirname(__FILE__))
    
    module_function
    
    def simulate(map_path)
      reader, writer = IO.pipe
      pid            = spawn("#{ROOT_DIR}/bin/run", in: map_path, out: writer)
      trap(:INT) do
        Process.kill(:INT, pid)
        exit
      end
      Process.detach(pid)
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
  end
end
