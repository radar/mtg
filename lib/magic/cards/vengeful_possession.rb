module Magic
  module Cards
    VengefulPossession = Sorcery("Vengeful Possession") do
      cost generic: 2, red: 1
    end

    class VengefulPossession < Sorcery
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
        target.gain_control_until_eot!(controller)
        target.untap!
        give_keyword(target, :haste)
        game.choices.add(MayChoice.new(actor: self))
      end
    end
  end
end
