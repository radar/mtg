module Magic
  module Cards
    ThoughtShucker = Creature("Thought Shucker") do
      cost generic: 1, blue: 1
      creature_type("Rat Rogue")
      power 1
      toughness 3
    end

    class ThoughtShucker < Creature
      # Threshold -- {1}{U}: Put a +1/+1 counter on this creature and draw a card. Activate only if there are
      # seven or more cards in your graveyard and only once.
      class ThresholdAbility < Magic::ActivatedAbility
        costs "{1}{U}"
        activate_only_once

        def requirements_met? = controller.graveyard.count >= 7

        def resolve!
          add_counter("+1/+1", to: source)
          draw_card
        end
      end

      def activated_abilities = [ThresholdAbility]
    end
  end
end
