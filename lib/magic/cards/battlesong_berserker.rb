module Magic
  module Cards
    BattlesongBerserker = Creature("Battlesong Berserker") do
      cost generic: 3, red: 1
      creature_type("Human Berserker")
      power 3
      toughness 4
    end

    class BattlesongBerserker < Creature
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 0)
            give_keyword(target, :menace)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => YouAttackTrigger }
    end
  end
end
