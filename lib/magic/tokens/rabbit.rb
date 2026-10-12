module Magic
  module Tokens
    # A 1/1 white Rabbit creature token.
    Rabbit = Token.create("Rabbit") do
      creature_type "Rabbit"
      power 1
      toughness 1
      colors :white
    end
  end
end
