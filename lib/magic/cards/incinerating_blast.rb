module Magic
  module Cards
    IncineratingBlast = Sorcery("Incinerating Blast") do
      cost generic: 4, red: 1
    end

    class IncineratingBlast < Sorcery
      class MayChoice < Magic::Choice::May
        class DiscardChoice < Magic::Choice::Discard
          def resolve!(**args)
            super(**args)
            draw_card
          end
        end

        def resolve!
          game.choices.add(DiscardChoice.new(actor: actor, player: controller))
        end
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        deal_damage(6, to: target)
        game.choices.add(MayChoice.new(actor: self))
      end
    end
  end
end
