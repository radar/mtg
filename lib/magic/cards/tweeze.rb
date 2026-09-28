module Magic
  module Cards
    Tweeze = Instant("Tweeze") do
      cost generic: 2, red: 1
    end

    class Tweeze < Instant
      class MayChoice < Magic::Choice::May
        # "If you do" (draw only if a card was actually discarded): wrap the draw in the
        # discard choice's own resolution rather than queuing both unconditionally.
        class DiscardChoice < Magic::Choice::Discard
          def initialize(actor:, player:)
            super(player: player)
            @actor = actor
          end

          def resolve!(card:)
            super
            trigger_effect(:draw_card)
          end
        end

        def resolve!
          game.add_choice(DiscardChoice.new(actor: actor, player: controller))
        end
      end

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 3)
        game.choices.add(MayChoice.new(actor: self))
      end
    end
  end
end
