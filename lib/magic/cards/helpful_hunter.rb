module Magic
  module Cards
    HelpfulHunter = Creature("Helpful Hunter") do
      cost generic: 1, white: 1
      creature_type("Cat")
      power 1
      toughness 1
    end

    class HelpfulHunter < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
