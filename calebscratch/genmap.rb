#!/usr/bin/ruby
if(ARGV.count != 7) 
  puts "command is ./genmap.rb x_size y_size lambda% rock% earth% walls% empty%"
  exit 0
end
length=ARGV[0].to_i
width=ARGV[1].to_i
total=percent_lambdas=ARGV[2].to_i
total+=percent_rocks=ARGV[3].to_i
total+=percent_earth=ARGV[4].to_i
total+=percent_walls=ARGV[5].to_i
total+=percent_empty=ARGV[6].to_i
$stderr.puts "arg0 = #{length}, arg1 = #{width}, lambdas = #{percent_rocks}, rocks = #{percent_rocks} " 
$stderr.puts "earth = #{percent_earth}, walls = #{percent_walls} " 
$stderr.puts "empty = #{percent_empty}" 
map = Array.new(length) { Array.new(width) {" "}}
if(total > 100)
  $stderr.puts "total percentage is #{total}, aborting"
  exit 0
end
if(total < 100)
  $stderr.puts "total percentage is less than 100%, will fill remainder with empty"
end

map[0].each { |temp|
  temp.replace("#")
}
$stderr.puts "map size is #{map.count}"
map.last.each { |temp|
  temp.replace("#")
}
map.each { |temp|
  temp[0].replace("#")
  temp.last.replace("#")
}

potentialspots=length*2+width*2-4-1
$stderr.puts "we need to evaluate #{potentialspots} spots on the map"
map[rand(length)][rand(width)].replace("L")
my_success=0
$stderr.puts "my_success is set to #{my_success}"
while my_success  < 1
  $stderr.puts "placing robot"
  randlength=rand(length)
  randwidth=rand(width)
  if( map[randlength][randwidth].eql? " " and " ".eql? " ")
    $stderr.puts "loc #{randlength},#{randwidth} (#{map[randlength][randwidth]}) is GREAT!!!"
    map[randlength][randwidth].replace("R")
    my_success = my_success+1
  else
    $stderr.puts " spot #{randlength} #{randwidth} is no good"
  end
end
#generate some lambdas
x=0
y=0
#add basic features to map
map.each { |myrow|
  x=x+1
  y=0
  myrow.each { |mycell|
   y=y+1
   if(mycell.eql? " ") 
     myrand=rand(1-100)
     #$stderr.puts "cell #{x},#{y} myrand is #{myrand} "
     #$stderr.puts "myrand is #{myrand} "
     if(myrand <= percent_lambdas)
        #$stderr.puts "making this a lambda"
        mycell.replace("\")
     elsif(myrand <= percent_rocks+percent_lambdas)
        #$stderr.puts "making this a rock"
        mycell.replace("*")
     elsif(myrand <= percent_rocks+percent_lambdas+percent_earth)
        #$stderr.puts "making this a earth"
        mycell.replace(".")
     elsif(myrand <= percent_rocks+percent_lambdas+percent_earth+percent_walls)
        #$stderr.puts "making this a wall"
        mycell.replace("#")
     else
        #$stderr.puts "making this a empty"
     end
   end
  } 
}
#add beard to map



map.each { |myrow|
  myrow.each { |mycell|
    print "#{mycell}"
  } 
  print "\n"
}
if(rand(1..2) == 1 )
  puts
  puts "Water #{rand(0..length)}"
  puts "Flooding #{rand(1..10)}"
  puts "Waterproof #{rand(0..15)}"
end
