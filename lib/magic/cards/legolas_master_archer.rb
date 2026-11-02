module Magic
  module Cards
    LegolasMasterArcher = Creature("Legolas, Master Archer") do
      cost generic: 1, green: 2
      legendary_creature_type("Elf Archer")
      keywords :reach
      power 1
      toughness 4
    end

    class LegolasMasterArcher < Creature
      # "Whenever you cast a spell that targets Legolas, put a +1/+1 counter on Legolas."
      class TargetedTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && event.targets.include?(actor)
        end

        def call
          add_counter "+1/+1", to: actor
        end
      end

      # "... Legolas deals damage equal to its power to up to one target creature."
      class DamageChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 0..1

        def resolve!(target:)
          return unless target

          deal_damage actor.power, to: target
        end

        def decline! = nil
      end

      # "Whenever you cast a spell that targets a creature you don't control, ..."
      class OpposingTargetTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && event.targets.any? do |target|
            target.is_a?(Magic::Permanent) && target.creature? && target.controller != controller
          end
        end

        def call
          choice = DamageChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge(Events::SpellCast => [TargetedTrigger, OpposingTargetTrigger]) { |_, old, new| [*old, *new] }
      end
    end
  end
end
