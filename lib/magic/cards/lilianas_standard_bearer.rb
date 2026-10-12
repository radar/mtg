module Magic
  module Cards
    LilianasStandardBearer = Creature("Liliana's Standard Bearer") do
      cost generic: 2, black: 1
      creature_type "Zombie Knight"
      keywords :flash
      power 3
      toughness 1
    end

    class LilianasStandardBearer < Creature
      # "When this creature enters, draw X cards, where X is the number of creatures that died under your control
      # this turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          died = game.current_turn.events.count { |e| e.is_a?(Events::CreatureDied) && e.permanent.controller == controller }
          trigger_effect(:draw_cards, number_to_draw: died) if died > 0
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
