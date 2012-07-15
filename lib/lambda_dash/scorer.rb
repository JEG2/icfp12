# TODO for project
# Available next move for robot UDLR that 1) will not kill robot 
#                                         2) actually moves robot
#                                         3) returns an array of those moves
#                                         4) if nill abort

# TODO here. Cell scorer complexity scorer and lambda concentration scorer.

module LambdaDash
  class Scorer

    MAX_LAMBDA_SCORE       = 75
    LAMBDA_COLLECTED_SCORE = 50
    LAMBDA_ABORTED_SCORE   = 25
    
    def self.manhattan_distance(x1, y1, x2, y2)
      (x1 - x2).abs + (y1 - y2).abs
    end
    
    def initialize(map, robot)
      @map   = map
      @robot = robot
      
      # on intialize build an array of lambda locations in map
      @lambda_locations = @map.lambdas
      
      # p @lambda_locations.map { |cell| [cell.x, cell.y] }
    end
    
        
    # current score

    # heat map -
    # create a array of arrays (or map)
    # figure out how to efficently sum the score.
    
    # Seed the heat map as follows:
    # Lambda cell set decramentor to 25
    # Set origin cell to decramentor value 25
    # Cell goes "dirty"

    #   Algorithm
    #   Decrament by 1
    #   Check cells around if clear (Dirt, Lambda, Empty) and "clean"
    #   Those cells set to decrament value (2nd step 24)
    #   Cells goes "dirty"

    # Knowledge of the cells that just got the 24 value now need to "grow
    # the heat" find and mark valid neighbors with a 23 and "dirty".
    
    # Rinse wash and repeat until all the squares in the map have been
    # marked dirty, or the decrmentor has reached zero.
    
    # Reset the cells dirty values to clean.
    
    # Back to the top and generate the heat from the next lambda on the map.
    
    # def heat_map
    #   heat_map = Array.new(@map.m) { Array.new(@map.n) { [0, "clean"] } }  
    #        # .each_slice(@map.n).to_a
    #   # heat_map[1][0]
    #   # p heat_map 
    # 
    #   remaining_lambdas.each do |cell|
    #     # p cell.x
    #     # p cell.y
    #     cell_stack = [heat_map[cell.x][cell.y]]
    #             
    #     cell_stack[0][0] = 25
    #     cell_stack[0][1].replace("dirty")
    # 
    #     cell_stack.each do |cell_prime|
    #       get_neighbors(cell, heat_map, cell_prime)
    #       # if ( heat_map[cell[0]+1][cell[1]].exist? ) and
    #       #                        ( heat_map[cell[0]+1][cell[1]].earth? or              
    #       #                           heat_map[cell[0]+1][cell[1]].empty? or                                    
    #       #                           heat_map[cell[0]+1][cell[1]].lambda? )
    #       #  p "cell passed some test\n"
    #       #  current_cell = heat_map [cell.x+1][cell.y]                        
    #       #  cell_stack << current_cell
    #       #  p current_cell[0] += cell[0] - 1
    #       #  p current_cell[1].replace("dirty")
    #       #         
    #       # end
    #     end
    #   end
    #   p heat_map
    # end
    # 
    # def get_neighbors (cell, heat_map, cell_prime)
    #   puts "I'm am here! #{cell.x}, #{cell.y}"
    #   puts "My neighbor up is   : #{cell.x}, #{cell.y + 1}"
    #   puts "My neighbor right is: #{cell.x + 1}, #{cell.y}"
    #   puts "My neighbor down  is: #{cell.x}, #{cell.y - 1}"
    #   puts "My neighbor left is : #{cell.x - 1}, #{cell.y}"
    #   
    #   if not @map[cell.x,cell.y+1].impassable?
    #           cell_stack << [heat_map[cell.x][cell.y+1]]
    #   end
    #   
    #   #if not [@map[cell.x+1][cell.y]].impassable?
    #   #        cell_stack << [heat_map[cell.x][cell.y+1]]
    #   #end
    #   
    #   # cell_stack << if not [heat_map[cell.x+1][cell.y]].impassable?
    #   #       cell_stack << if not [heat_map[cell.x][cell.y-1]].impassable?
    #   #       cell_stack << if not [heat_map[cell.x-1][cell.y]].impassable?
    #   puts "cell_stack is #{cell_stack}"
    # end
    
    def score_abandon_now
      @robot.score + @robot.lambdas_collected * LAMBDA_ABORTED_SCORE
    end
       
    # Adding the robots current score add all the Lambda's at 25
    # add his lambda's collect plus the number left on the board times 50
    
    # Current score plus lambda's collected
    
    def james_algorithm
      @robot.lambdas_collected                     * LAMBDA_COLLECTED_SCORE +
      (@lambda_locations.size + @map.horocks.size) * MAX_LAMBDA_SCORE       +
      @robot.score
    end
    
    def eds_algorithm
      @lambda_locations.size * 75 - exit_distance - distance_to_farthest_lambda
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
            distance = distance_between( lambda.x,
                                         lambda.y,
                                         @robot.x,
                                         @robot.y )
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
      l = @lambda_locations.max_by { |cell|
        distance_between(cell.x, cell.y, @robot.x, @robot.y)
      }
      [l.x, l.y] if l
    end
    
    def distance_to_farthest_lambda
      lambda = farthest_lambda
      if lambda
        (lambda[0] - @robot.x).abs + (lambda[1] - @robot.y).abs
      else
        0
      end
    end
    
    def remaining_lambdas
      @lambda_locations = @map.select { |cell| cell.lambda? }
    end
    
    def total_lambdas_on_map
      @map.count { |cell| cell.lambda? }
    end
    
    def exit_distance
      lift = @map.lifts.first
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