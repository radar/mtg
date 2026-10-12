module Magic
  module Tokens
    # A 1/1 black Snail creature token.
    Snail = Token.create("Snail") do
      creature_type "Snail"
      power 1
      toughness 1
      colors :black
    end
  end
end
