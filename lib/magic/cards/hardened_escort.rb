module Magic
  module Cards
    HardenedEscort = Creature("Hardened Escort") do
      cost generic: 2, white: 1
      creature_type("Human Soldier")
      power 2
      toughness 4
    end

    class HardenedEscort < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 0)
            trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
