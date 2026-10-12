module Magic
  module Tokens
    # A 1/1 blue Fish creature token (the gift of "Gift a tapped Fish").
    Fish = Token.create("Fish") do
      creature_type "Fish"
      power 1
      toughness 1
      colors :blue
    end
  end
end
