module LambdaDash
  class Map_Calculator
    # On Abort
    #   All lambdas collected multiply by 25 plus current score
    # On Immediate Abort
    #   Multiply by collected lambdas 25 plus current score
    # On Exit
    #   All lambdas mulitply by 50
    # Decision points
    #   If the steps to the lift are more/less then the difference on Abort or Exit by lift
       
  end
end
 
# Notes:
#   If you have make a move under a rock you have to have a way to exit to the left or the right

Search optimizer ideas:

  Quadrants to determine a honeypot score for parts of the map.
  
  This score should depend upon the distance of the quadrant to the robot.  As in the easiest way/path for the robot to move to the quadrant and the difference bewtween the possible points scored and the cost of moving there.
  
  Micro and Macro searching.