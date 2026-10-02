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
            trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 0)
            trigger_effect(:grant_keyword, target: target, keyword: :menace)
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
