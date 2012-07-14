#!/usr/bin/ruby
file = File.new("metadata.dat", "r")
counter=0;
h= Hash.new()
while (line = file.gets)
  puts "#{counter}: #{line}"
  temp=line.split(' ')
  h[temp[0]] = temp[1]
  puts "new entry #{temp[0]} is #{h[temp[0]]}"
end

def parsemap(map)
  
end
