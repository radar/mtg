module Magic
  module Cards
    MidnightSnack = Enchantment("Midnight Snack") do
      cost generic: 2, black: 1
    end

    class MidnightSnack < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}, Sacrifice {this}"

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          trigger_effect(:lose_life, target: target, life: game.current_turn.events.select { |e| e.is_a?(Events::LifeGain) && e.player == controller }.sum(&:life))
        end
      end

      def activated_abilities = [ActivatedAbility]

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (game.current_turn.events.any? { |e| e.is_a?(Events::CreatureAttacked) && e.attacker.controller == controller })
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
