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
            trigger_effect(:draw_card)
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
        trigger_effect(:deal_damage, target: target, damage: 6)
        game.choices.add(MayChoice.new(actor: self))
      end
    end
  end
end
