module Magic
  module Cards
    WhiskerquillScribe = Creature("Whiskerquill Scribe") do
      cost generic: 1, red: 1
      creature_type("Mouse Citizen")
      power 2
      toughness 2
    end

    class WhiskerquillScribe < Creature
      # Valiant -- you may discard a card. If you do, draw a card.
      class ValiantTrigger < TriggeredAbility::Valiant
        class DiscardChoice < Magic::Choice::Discard
          def resolve!(card:)
            super
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
