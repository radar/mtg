module Magic
  module Tokens
    # A 1/1 blue and red Otter creature token with prowess.
    Otter = Token.create("Otter") do
      creature_type "Otter"
      power 1
      toughness 1
      colors :blue, :red
      keywords :prowess
    end
  end
end
