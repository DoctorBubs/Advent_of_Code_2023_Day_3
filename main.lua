local text = io.input("input.txt")

local input = io.read("*all")


--We use lume fo easier functional programming.

local lume = require "lume"
--Symbols is a hash table that will contain a true value for each symbol we need to look for.
local symbols = {}



--This function will take any string except ".", and make sure that symbols[string] is set to true.
local function symbol_add(s)
  
  if s == "." then 
    return
  else
    if not symbols[s] then
      symbols[s] = true
    end
  end
end

--Takes a string, and checks if it is a symbol.
local function symbol_check(s)
  return symbols[s]
end

-- For each line in uput, we look at every non alphanumeric character, and if it isn't "*" we register it as a symbol in symbols
for line in string.gmatch(input,"%C+") do 
  for symbol in string.gmatch(line,"%W") do
    symbol_add(symbol)
  end
end


--[[ We keep an array for each tile in the map that contains a symbol or a reference to a table with a number. 
Each tile contains an x and y position that corresponds to a char in the string, with y y position being an abstraction of each new line.
]]
local all_symbol_tiles = {}
local all_number_tiles = {}

-- We use this to keep track of the curreny y position when we create a new tile, it goes up by 1 for each line in the string.
local y_counter = 0
-- We loop through each line in the input.
for line in string.gmatch(input,"%C+") do 
  
  y_counter = y_counter + 1
  local leng = string.len(line)
  
  
  for x_counter = 1,string.len(line) do
    --[[ and we fill the rows with tiles. If the char we are looking at contains a symbol, we mark the tile as containing a symbol, we save the x and y position in the tile,
    and add the tile to all_symbol_tiles]] 
    local new_tile = {}
    local occupant = string.sub(line,x_counter,x_counter)
    if symbol_check(occupant) then
      new_tile.symbol = occupant
      new_tile.x_pos = x_counter
      new_tile.y_pos = y_counter
      table.insert(all_symbol_tiles,new_tile)
    end
    
  end
  -- Next, we loop through the line to find all numbers.
  local num_starting_point = 1
  while true do
    local start_index,end_index= string.find(line,"%d+",num_starting_point)
    --If we can not find any more numbers, we break the loop.
    if not start_index then
      break
    else
      --If we find a number- we track where the number starts and end in the string.
      local value = string.sub(line,start_index,end_index)
      -- We store the full number in a table.
      local shared_table = { value = value}
      --[[ For each digit in the number, we create a new number with an x and y position that corresponds with the digits position in the string.
      Each tile also contains a pointer to the shared table that holds the full number]]
      for x = start_index,end_index do
        local tile ={}
        tile.has_num = true
        tile.shared_value = shared_table
        tile.x_pos = x
        tile.y_pos = y_counter
        table.insert(all_number_tiles,tile)
      end
      num_starting_point = end_index + 1
    end
  end
end
-- This function returns true if the distance between two tiles equals 1.
local function dist_1(a,b)
  return math.abs(a.x_pos - b.x_pos) <= 1 and math.abs(a.y_pos - b.y_pos) <= 1 

end

--[[ This function takes an tile that contains a symbol,and creates an array.
For each number tile that is one space away,the tile's shared value table is inserted into the array.
The function then clears the array of duplicates]]
local function get_adjacent_shared_tiles(symbol_tile)
  
  return lume.chain(all_number_tiles)
  :filter(function(num_tile) return dist_1(num_tile,symbol_tile)end)
  :map(function(num_tile) return num_tile.shared_value end)
  :unique()
  :result()
  
end

-- This array will contain every shared value table that is next to a symbol.
local adjacent_shared_values = {}

--We get the adjecent shared values for each symbol tile
for _,sym_tile in ipairs(all_symbol_tiles) do
  local map_arr = get_adjacent_shared_tiles(sym_tile)
  -- and then insert those in adjacent_shared_values
  for i, shared_value in ipairs(map_arr) do
    table.insert(adjacent_shared_values,shared_value)
  end
end
--[[ Finally, we clear adjecent_shared_values of all duplicate shared value table, then extract the actual value from each table, and add up each value to gvet the solution.
]]
local result = lume.chain(adjacent_shared_values)
  :unique()
  :map(function(t) return t.value end)
  :reduce(function(a,b) return a + b end)
  :result()

print(result)
