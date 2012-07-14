require_relative "../lib/lambda_dash"

describe LambdaDash::Robot do
  #
  # ######
  # #. *R#
  # #  \.#
  # #\ * #
  # L  .\#
  # ######
  #
  let(:map)   { LambdaDash::Map.new(1)     }
  let(:robot) { LambdaDash::Robot.new(map) }

  it "knows its own location" do
    expect(robot.x).to eq(5)
    expect(robot.y).to eq(5)
  end

  it "moves the robot" do
    robot.move("D")
    expect(map[5, 5].empty?).to be_true
    expect(map[5, 4].robot?).to be_true
  end

  it "clears earth as it moves" do
    robot.move("DL")
    expect(map[5, 4].empty?).to be_true
    expect(map[4, 4].robot?).to be_true
  end

  it "collects lambdas as it moves" do
    robot.move("DLL")
    expect(map[4, 4].empty?).to        be_true
    expect(map[3, 4].robot?).to        be_true
    expect(robot.lambdas_collected).to eq(1)
  end

  it "pushes rocks as it moves" do
    robot.move("L")
    expect(map[5, 5].empty?).to be_true
    expect(map[4, 5].robot?).to be_true
    expect(map[3, 5].rock?).to  be_true
  end

  it "cannot push rocks through objects" do
    robot.move("LL")
    expect(map[5, 5].empty?).to be_true
    expect(map[4, 5].robot?).to be_true
    expect(map[3, 5].rock?).to  be_true
  end

  it "cannot move into a wall" do
    robot.move("R")
    expect(map[5, 5].robot?).to be_true
  end

  it "can chose to do nothing" do
    robot.move("W")
    expect(map[5, 5].robot?).to be_true
  end

  it "can end the game" do
    robot.move("A")
    expect(robot.game_over?).to be_true
  end

  it "tracks a score" do
    robot.move("D")
    expect(robot.score).to eq(-1)

    robot.move("L")
    expect(robot.score).to eq(23)
  end
end