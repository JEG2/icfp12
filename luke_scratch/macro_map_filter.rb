module LambdaDash
  class MacroMapFilter
    
   def initialize(map)
     @map = map
   end 
   
   def macro_filter
     @map.quadrant_size
   end
   
   private
   
   def quadrant_size
     "I am here"
   end
   
  end
end