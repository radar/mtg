module Magic
  module Cards
    TrygonPredator = Creature("Trygon Predator") do
      cost generic: 1, green: 1, blue: 1
      creature_type("Beast")
      keywords :flying
      power 2
      toughness 3
    end

    class TrygonPredator < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        class MayChoice < Magic::Choice::May
          class TargetChoice < Magic::Choice::Targeted
            def choices
              (battlefield.not_controlled_by(controller).artifacts + battlefield.not_controlled_by(controller).enchantments)
            end

            def choice_amount = 1

            def resolve!(target:)
              trigger_effect(:destroy_target, target: target)
            end
          end

          def resolve!
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          return if (battlefield.not_controlled_by(controller).artifacts + battlefield.not_controlled_by(controller).enchantments).none?
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
