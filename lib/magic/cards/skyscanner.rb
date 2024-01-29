module Magic
  module Cards
    Skyscanner = Creature("Skyscanner") do
      cost generic: 3
      creature_type "Thopter"
      power 1
      toughness 1
      keywords :flying

      enters_the_battlefield do
        permanent.trigger_effect(:draw_cards)
      end
    end
  end
end
