module Magic
  module Tokens
    # "a 1/1 white Halfling creature token"
    Halfling = Token.create("Halfling") do
      creature_type "Halfling"
      power 1
      toughness 1
      colors :white
    end
  end
end
