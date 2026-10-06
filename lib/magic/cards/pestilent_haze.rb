module Magic
  module Cards
    class PestilentHaze < Sorcery
      card_name "Pestilent Haze"
      cost generic: 1, black: 2

      # "All creatures get -2/-2 until end of turn."
      class ShrinkCreatures < Mode
        def resolve!
          battlefield.creatures.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: -2, toughness: -2)
          end
        end
      end

      # "Remove two loyalty counters from each planeswalker."
      class RemoveLoyalty < Mode
        def resolve!
          battlefield.planeswalkers.each { |planeswalker| planeswalker.change_loyalty!(-2) }
        end
      end

      modes ShrinkCreatures, RemoveLoyalty
      choose_modes 1
    end
  end
end
