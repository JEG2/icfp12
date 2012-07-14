# TODO for project
# Available next move for robot UDLR that 1) will not kill robot 
#                                         2) actually moves robot
#                                         3) returns an array of those moves
#                                         4) if nill abort

# TODO here. Cell scorer complexity scorer and lambda concentration scorer.

module LambdaDash
  class Scorer
    def initialize(map, robot)
      @map              = map
      @robot            = robot
      @max_lambda_score = 75
      
      # on intialize build an array of lambda locations in map
      @lambda_locations = @map.select { |cell| cell.lambda? }
      
      # p @lambda_locations.map { |cell| [cell.x, cell.y] }
    end
    
        
    # current score
    
    # abondon right now score
    
    # potential total score (collecting all lambda's and exiting the lift)
    
    def eds_algorithm
      total_lambdas_on_map * 75 - exit_distance - distance_to_farthest_lambda
    end
    
    def nearest_lambda
      if total_lambdas_on_map > 0
        remaining_lambdas
        a_lambda = @lambda_locations.first
        distance = distance_between( a_lambda.x,
                                     a_lambda.y,
                                     @robot.x,
                                     @robot.y )
        lambda_location = [ a_lambda.x, a_lambda.y ]
        @lambda_locations.each do |lambda|
          if distance_between( lambda.x, 
                               lambda.y,
                               @robot.x,
                               @robot.y ) < distance
            distance = (lambda.x - @robot.x).abs + (lambda.y - @robot.y).abs
            lambda_location = [lambda.x, lambda.y]
          end
        end
        return lambda_location
      else
        nil
      end
    end
    
    def distance_to_nearest_lambda
      lambda = nearest_lambda
      if lambda
        (lambda[0] - @robot.x).abs + (lambda[1] - @robot.y).abs
      else
        nil
      end
    end
    
    def farthest_lambda
      if total_lambdas_on_map > 0
        remaining_lambdas
        a_lambda = @lambda_locations.first
        distance = distance_between( a_lambda.x,
                                     a_lambda.y,
                                     @robot.x,
                                     @robot.y )
        lambda_location = [ a_lambda.x, a_lambda.y ]
        
        @lambda_locations.each do |lambda|
          if distance_between( lambda.x, 
                               lambda.y,
                               @robot.x,
                               @robot.y ) > distance
            distance = (lambda.x - @robot.x).abs + (lambda.y - @robot.y).abs
            lambda_location = [lambda.x, lambda.y]
          end
        end
        return lambda_location
      else
        nil
      end
    end
    
    def distance_to_farthest_lambda
      lambda = farthest_lambda
      if lambda
        (lambda[0] - @robot.x).abs + (lambda[1] - @robot.y).abs
      else
        nil
      end
    end
    
    def remaining_lambdas
      @lambda_locations = @map.select { |cell| cell.lambda? }
    end
    
    def total_lambdas_on_map
      @map.count { |cell| cell.lambda? }
    end
    
    def exit_distance
      lift = @map.find { |cell| cell.lift? }
      (lift.x - @robot.x).abs + (lift.y - @robot.y).abs
    end
    
    # def algo_manhanttan
    #   @map.count { |cell| }
    # end
    
    private
    
    def distance_between ( x_1, y_1, x_2, y_2 )
      (x_1 - x_2).abs + (y_1 - y_2).abs
    end

  end
end