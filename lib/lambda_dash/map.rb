module LambdaDash
  class Map
    class Cell
      def initialize(ascii, x, y)
        @ascii = ascii
        @x     = x
        @y     = y
      end

      attr_reader :x, :y
      attr_writer :ascii

      def wall?
        @ascii == "#"
      end

      def closed_lift?
        @ascii == "L"
      end

      def open_lift?
        @ascii == "O"
      end

      def lift?
        closed_lift? or open_lift?
      end

      def earth?
        @ascii == "."
      end

      def lambda?
        @ascii == "\\"
      end

      def robot?
        @ascii == "R"
      end

      def rock?
        @ascii == "*"
      end

      def empty?
        @ascii == " "
      end

      def impassable?
        wall? or closed_lift?
      end

      def to_s
        @ascii
      end
    end
    
    def self.path(name)
      if name.is_a?(Integer) or name =~ /\A\d+\z/
        File.expand_path( "../../data/contest#{name}.map",
                          File.dirname(__FILE__) )
      elsif name !~ %r{[./]}
        File.expand_path( "../../data/#{name}.map",
                          File.dirname(__FILE__) )
      else
        name
      end
    end

    def initialize(map_name_or_cells)
      if map_name_or_cells.is_a? Array
        build_map(map_name_or_cells)
      else
        load_map(map_name_or_cells)
      end
    end

    include Enumerable

    def n
      @cells.first.size
    end

    def m
      @cells.size
    end

    def max_moves
      n * m
    end

    def [](x, y)
      @cells[m - y][x - 1]
    end

    def []=(x, y, ascii)
      self[x, y].ascii = ascii
    end

    def each
      1.upto(m) do |y|
        1.upto(n) do |x|
          yield self[x, y]
        end
      end
    end

    def update(robot)
      updates = {cells: [ ], lifts: [ ], lambdas: 0}
      each do |cell|
        update_cell(cell, updates)
      end
      if updates[:lambdas].zero?
        updates[:lifts].each do |lift_x, lift_y|
          self[lift_x, lift_y] = "O"
        end
      end
      updates[:cells].each do |x, y, ascii|
        self[x, y] = ascii
        if ascii == "*" and y > 1 and self[x, y - 1].robot?
          robot.die
        end
      end
    end

    def to_s
      @cells.map { |row| "#{row.join}\n" }.join
    end

    private

    def build_map(cells)
      @cells = cells.map.with_index { |row, y|
        row.map.with_index { |ascii, x| Cell.new(ascii, x + 1, cells.size - y) }
      }
    end

    def load_map(name)
      lines  = File.readlines(self.class.path(name)).map(&:chomp)
      n      = lines.map(&:size).max
      @cells = Array.new(lines.size) { |y|
        Array.new(n) { |x| Cell.new(lines[y][x] || " ", x + 1, lines.size - y) }
      }
    end

    def update_cell(cell, updates)
      x, y = cell.x, cell.y
      if cell.closed_lift?
        updates[:lifts] << [x, y]
      elsif cell.lambda?
        updates[:lambdas] += 1
      elsif cell.rock? and y > 1
        if self[x, y - 1].empty?
          updates[:cells] << [x, y,     " "] <<
                             [x, y - 1, "*"]
        elsif self[x, y - 1].rock?
          if x < n and self[x + 1, y].empty? and self[x + 1, y - 1].empty?
            updates[:cells] << [x,     y,     " "] <<
                               [x + 1, y - 1, "*"]
          elsif x > 1 and self[x - 1, y].empty? and self[x - 1, y - 1].empty?
            updates[:cells] << [x,     y,     " "] <<
                               [x - 1, y - 1, "*"]
          end
        elsif self[x, y - 1].lambda? and
              x < n                  and
              self[x + 1, y].empty?  and
              self[x + 1, y - 1].empty?
          updates[:cells] << [x,     y,     " "] <<
                             [x + 1, y - 1, "*"]
        end
      end
    end
  end
end