module Magic
  module Tokens
    # A 1/1 black Bat creature token with flying.
    Bat = Token.create("Bat") do
      creature_type "Bat"
      power 1
      toughness 1
      colors :black
      keywords :flying
    end
  end
end
