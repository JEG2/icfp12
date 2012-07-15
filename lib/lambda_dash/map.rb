module LambdaDash
  class Map
    class Cell
      def initialize(ascii, x, y)
        @ascii = ascii
        @x     = x
        @y     = y
      end

      attr_reader :x, :y

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
      @metadata = {water: 0, flooding: 0, waterproof: 10}
      if map_name_or_cells.is_a? Array
        build_map(map_name_or_cells)
      else
        load_map(map_name_or_cells)
      end
      @water_level = @metadata[:water]
      @lambdas     = [ ]
      @lifts       = [ ]
      @rocks       = [ ]
      each do |cell|
        if cell.lambda?
          @lambdas << cell
        elsif cell.lift?
          @lifts << cell
        elsif cell.rock?
          @rocks << cell
        end
      end
    end

    def initialize_copy(_)
      super
      @cells   = @cells.map { |row| row.dup }
      @lambdas = @lambdas.dup
      @lifts   = @lifts.dup
      @rocks   = @rocks.dup
    end

    attr_reader :metadata, :water_level, :lambdas, :lifts, :rocks

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
      mx  = x - 1
      my  = m - y
      old = @cells[my][mx]
      if old.rock?
        @rocks.delete(old)
      end
      @cells[my][mx] = Cell.new(ascii, x, y)
      if ascii == "*"
        @rocks << @cells[my][mx]
        @rocks.sort_by! { |cell| [cell.x, cell.y] }
      end
    end

    def each
      1.upto(m) do |y|
        1.upto(n) do |x|
          yield self[x, y]
        end
      end
    end

    def update(robot)
      updates = [ ]
      @rocks.each do |cell|
        update_cell(cell, updates)
      end
      if @lambdas.empty?
        @lifts.each do |lift|
          self[lift.x, lift.y] = "O"
        end
      end
      updates.each do |x, y, ascii|
        self[x, y] = ascii
        if ascii == "*" and y > 1 and self[x, y - 1].robot?
          robot.die
        end
      end
      @water_level  = @metadata[:water]
      @water_level += robot.move_count / @metadata[:flooding] \
        if @metadata[:flooding].nonzero?
      robot.check_water_level(@water_level, @metadata[:waterproof])
      robot.clear_score
      clear_hash_key
    end

    def clear_hash_key
      @hash_key = nil
    end

    def hash_key
      @hash_key ||= @cells.join
    end

    def to_s
      @cells.map.with_index { |row, y|
        line = "#{row.join}\n"
        if m - y == @water_level
          line.sub!(/\A\s*#/)    { |pre| "~" * pre.size }
          line.sub!(/#[ \t]*\Z/) { |pos| "~" * pos.size }
        end
        line
      }.join
    end

    private

    def build_map(cells)
      @cells = cells.map.with_index { |row, y|
        row.map.with_index { |ascii, x| Cell.new(ascii, x + 1, cells.size - y) }
      }
    end

    def load_map(name)
      lines = File.readlines(self.class.path(name)).map(&:chomp)
      while lines.last =~ /\A(\w+)\s+(\d+)/
        @metadata[$1.downcase.to_sym] = $2.to_i
        lines.pop
      end
      lines.pop unless lines.last =~ /\S/
      n      = lines.map(&:size).max
      @cells = Array.new(lines.size) { |y|
        Array.new(n) { |x| Cell.new(lines[y][x] || " ", x + 1, lines.size - y) }
      }
    end

    def update_cell(cell, updates)
      x, y = cell.x, cell.y
      if y > 1
        if self[x, y - 1].empty?
          updates.push([x, y, " "], [x, y - 1, "*"])
        elsif self[x, y - 1].rock?
          if x < n and self[x + 1, y].empty? and self[x + 1, y - 1].empty?
            updates.push([x, y, " "], [x + 1, y - 1, "*"])
          elsif x > 1 and self[x - 1, y].empty? and self[x - 1, y - 1].empty?
            updates.push([x, y, " "], [x - 1, y - 1, "*"])
          end
        elsif self[x, y - 1].lambda? and
              x < n                  and
              self[x + 1, y].empty?  and
              self[x + 1, y - 1].empty?
          updates.push([x, y, " "], [x + 1, y - 1, "*"])
        end
      end
    end
  end
end
