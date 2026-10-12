module Magic
  module Cards
    BywayBarterer = Creature("Byway Barterer") do
      cost generic: 2, red: 1
      creature_type("Raccoon Rogue")
      keywords :menace
      power 3
      toughness 3
    end

    class BywayBarterer < Creature
      # Whenever you expend 4, you may discard your hand. If you do, draw two cards.
      class ExpendTrigger < TriggeredAbility::Expend
        class MayChoice < Magic::Choice::May
          def resolve!
            [*controller.hand.cards].each(&:discard!)
            trigger_effect(:draw_cards, number_to_draw: 2)
          end
        end

        def threshold = 4

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
