module Magic
  module Cards
    class Dreadmobile < Vehicle
      card_name "Dreadmobile"
      cost generic: 2, black: 1
      power 3
      toughness 3
      crew 1
      keywords :menace

      # "{1}, Sacrifice another artifact or creature: Put a +1/+1 counter on this Vehicle."
      class GrowAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice another artifact or creature"

        def resolve!
          add_counter "+1/+1", to: source
        end
      end

      def activated_abilities = [*super, GrowAbility]
    end
  end
end
