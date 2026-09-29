module Magic
  module Cards
    class VoraciousTomeSkimmer < Creature
      card_name "Voracious Tome-Skimmer"
      cost "{U/B}{U/B}{U/B}"
      creature_type "Faerie Rogue"
      power 2
      toughness 3
      keywords :flying

      class MayPayLifeChoice < Magic::Choice::May
        # "... you may pay 1 life. If you do, draw a card." (Can't pay life you don't have.)
        def resolve!
          return unless controller.life >= 1

          trigger_effect(:lose_life, target: controller, life: 1)
          trigger_effect(:draw_card)
        end
      end

      # "Whenever you cast a spell during an opponent's turn, you may pay 1 life. If you do, draw a
      # card."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && !controllers_turn?

        def call
          game.choices.add(MayPayLifeChoice.new(actor:))
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
