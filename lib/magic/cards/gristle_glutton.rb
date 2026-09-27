module Magic
  module Cards
    GristleGlutton = Creature("Gristle Glutton") do
      cost generic: 1, red: 1
      creature_type("Goblin Scout")
      power 1
      toughness 3
    end

    class GristleGlutton < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Blight 1"

        # "Discard a card. If you do, draw a card." -- a mandatory (not "may") discard,
        # so the draw only runs once a card is actually discarded (empty hand: nothing
        # to discard, no draw), not unconditionally alongside it. Mirrors the "may X. If
        # you do, Y" nesting pattern (docs/patterns/choices.md) minus the outer May.
        class DiscardChoice < Magic::Choice::Discard
          def resolve!(card:)
            super
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end

        def resolve!
          game.choices.add(DiscardChoice.new(actor: source, player: controller))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
