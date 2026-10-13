module Magic
  module Cards
    Skyscanner = Creature("Skyscanner") do
      cost generic: 3
      creature_type "Thopter"
      power 1
      toughness 1
      keywords :flying

      enters_the_battlefield do
        draw_card
      end
    end
  end
end
