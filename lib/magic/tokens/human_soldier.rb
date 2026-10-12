module Magic
  module Tokens
    # "a 1/1 white Human Soldier creature token" (Recruit, Magic::Recruit)
    HumanSoldier = Token.create("Human Soldier") do
      creature_type "Human Soldier"
      power 1
      toughness 1
      colors :white
    end
  end
end
