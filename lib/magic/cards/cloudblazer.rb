module Magic
  module Cards
    Cloudblazer = Creature("Cloudblazer") do
      cost generic: 3, white: 1, blue: 1
      creature_type("Human Scout")
      keywords :flying
      power 2
      toughness 2
    end

    class Cloudblazer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 2)
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
