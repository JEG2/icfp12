require_relative "../lib/lambda_dash"

describe LambdaDash::Scorer do
  #
  # ######
  # #. *R#
  # #  \.#
  # #\ * #
  # L  .\#
  # ######
  #
  let(:map)    { LambdaDash::Map.new(1)            }
  let(:robot)  { LambdaDash::Robot.new(map)        }
  let(:scorer) { LambdaDash::Scorer.new(map,robot) }
  
  it "Knows sum total of lambda's left on map" do
    expect(scorer.total_lambdas_on_map).to eq(3)
  end
  
  it "Knows Manhattan distance to the lift" do
    expect(scorer.exit_distance).to eq(7)
  end
  
  it "Knows the number of Lambas a distance around the robot" do
    
  end

  it "Knows the distance to the farthest Lambda" do
    expect(scorer.distance_to_farthest_lambda). to eq(5)
  end
  
  it "Knows the location of farthest Lambda to the robot" do
    expect(scorer.farthest_lambda).to eq( [ 2, 3 ] )
  end
  
  it "Knows the distance to the nearest Lambda" do
    expect(scorer.distance_to_nearest_lambda). to eq(2)
  end
  
  it "Knows the location of nearest Lambda to the robot" do
    expect(scorer.nearest_lambda).to eq( [ 4, 4 ] )
  end
  
  it "" do
    
  end
  
  # it "Calculates a score potential using a manhattan algorthim with a lambda distance from optmized line." do
  #   expect(scorer.algo_manhanttan).to eq
  # end
  
end