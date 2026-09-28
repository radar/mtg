module Magic
  module Cards
    MistmeadowCouncil = Creature("Mistmeadow Council") do
      cost generic: 4, green: 1
      creature_type "Kithkin Advisor"
      power 4
      toughness 3
    end

    class MistmeadowCouncil < Creature
      # "This spell costs {1} less to cast if you control a Kithkin."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { game.battlefield.controlled_by(player).any? { |permanent| permanent.type?("Kithkin") } ? -1 : 0 } }
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
