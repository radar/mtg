module Magic
  module Tokens
    # "a 2/2 red Dwarf creature token" (Dwarven Shortsword, Fili the Pathfinder)
    Dwarf = Token.create("Dwarf") do
      creature_type "Dwarf"
      power 2
      toughness 2
      colors :red
    end
  end
end
