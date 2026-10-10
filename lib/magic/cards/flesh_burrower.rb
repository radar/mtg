module Magic
  module Cards
    FleshBurrower = Creature("Flesh Burrower") do
      cost generic: 1, green: 1
      creature_type("Insect")
      keywords :deathtouch
      power 2
      toughness 2
    end

    class FleshBurrower < Creature
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
            trigger_effect(:grant_keyword, target: target, keyword: :deathtouch)
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
