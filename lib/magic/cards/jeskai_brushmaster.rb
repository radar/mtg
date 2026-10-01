module Magic
  module Cards
    JeskaiBrushmaster = Creature("Jeskai Brushmaster") do
      cost generic: 1, blue: 1, red: 1, white: 1
      creature_type("Orc Monk")
      keywords :double_strike, :prowess
      power 2
      toughness 4
    end
  end
end
