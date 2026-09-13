module Magic
  module Cards
    VoiceOfMany = Creature("Voice of Many") do
      cost generic: 2, green: 2
      creature_type "Elf Druid"
      power 3
      toughness 3
    end

    class VoiceOfMany < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          cards_to_draw = opponents.count { |opponent| opponent.creatures.count < controller.creatures.count }
          actor.trigger_effect(:draw_cards, number_to_draw: cards_to_draw) if cards_to_draw.positive?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
