require_relative "../lib/lambda_dash"

describe LambdaDash::Map do
  def load_map(name)
    LambdaDash::Map.new(name)
  end

  def build_map_with_robot(map)
    map   = LambdaDash::Map.new(map.lines.map { |line| line.strip.split("") })
    robot = LambdaDash::Robot.new(map)
    [map, robot]
  end
  
  context "given a map name" do
    it "makes a path from a contest number" do
      path = File.expand_path("../data/contest1.map", File.dirname(__FILE__))
      expect(LambdaDash::Map.path(1)).to eq(path)
    end

    it "makes a path from a map name" do
      path = File.expand_path("../data/map_name.map", File.dirname(__FILE__))
      expect(LambdaDash::Map.path("map_name")).to eq(path)
    end

    it "passes through full paths" do
      path = "full/path.map"
      expect(path).to eq(path)
    end
  end

  context "when read" do
    it "knows the map size" do
      seven = load_map(7)
      expect(seven.n).to eq(19)
      expect(seven.m).to eq(9)

      nine = load_map(9)
      expect(nine.n).to eq(26)
      expect(nine.m).to eq(17)

      ten = load_map(10)
      expect(ten.n).to eq(29)
      expect(ten.m).to eq(24)
    end
  end
  
  context "loaded from a map file" do
    #
    # ######
    # #. *R#
    # #  \.#
    # #\ * #
    # L  .\#
    # ######
    #
    let(:map) { load_map(1) }

    it "recognizes the various types of cells" do
      expect(map[1, 1].wall?).to        be_true
      expect(map[1, 2].closed_lift?).to be_true
      expect(map[1, 2].open_lift?).to   be_false
      expect(map[1, 2].lift?).to        be_true
      expect(map[2, 5].earth?).to       be_true
      expect(map[5, 2].lambda?).to      be_true
      expect(map[5, 5].robot?).to       be_true
      expect(map[4, 3].rock?).to        be_true
      expect(map[2, 2].empty?).to       be_true
    end

    it "recognizes impassable cells" do
      expect(map[1, 2].impassable?).to be_true
      expect(map[2, 2].impassable?).to be_false
    end

    it "knows the max moves" do
      expect(map.max_moves).to eq(map.n * map.m)
    end

    it "can iterate through cells" do
      cells = [ ]
      1.upto(map.m) do |y|
        1.upto(map.n) do |x|
          cells << map[x, y]
        end
      end

      expect(map.to_a).to eq(cells)

      map.each do |cell|
        expect(cell).to eq(cells.shift)
      end
    end

    it "marks each cell with coordinates" do
      lift = map.find(&:lift?)
      expect(lift.x).to eq(1)
      expect(lift.y).to eq(2)
    end
  end

  context "when updating" do
    it "opens lifts when all lambdas are gone" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #   #
      L R #
      #   #
      #####
      END_MAP
      map.update(robot)
      expect(map[1, 3].open_lift?).to be_true
    end

    it "doesn't open a lift if lambdas remain" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #  \#
      L R #
      #   #
      #####
      END_MAP
      map.update(robot)
      expect(map[1, 3].open_lift?).to be_false
    end

    it "drops rocks" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #  *#
      L   #
      #R  #
      #####
      END_MAP
      map.update(robot)
      expect(map[4, 4].rock?).to be_false
      expect(map[4, 3].rock?).to be_true
    end

    it "drops rocks to the right" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #   #
      L * #
      #R* #
      #####
      END_MAP
      map.update(robot)
      expect(map[3, 3].rock?).to be_false
      expect(map[4, 2].rock?).to be_true
    end

    it "drops rocks to the left" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #   #
      L  *#
      #R *#
      #####
      END_MAP
      map.update(robot)
      expect(map[4, 3].rock?).to be_false
      expect(map[3, 2].rock?).to be_true
    end

    it "drops rocks to the right of lambda" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #   #
      L * #
      #R\ #
      #####
      END_MAP
      map.update(robot)
      expect(map[3, 3].rock?).to be_false
      expect(map[4, 2].rock?).to be_true
    end

    it "kills the robot if he is under a falling rock" do
      map, robot = build_map_with_robot(<<-'END_MAP')
      #####
      #*  #
      L   #
      #R  #
      #####
      END_MAP
      map.update(robot)
      expect(robot.game_over?).to be_true
    end
  end
end
