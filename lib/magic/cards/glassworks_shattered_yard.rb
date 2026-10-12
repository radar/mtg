module Magic
  module Cards
    class GlassworksShatteredYard < Room
      class Glassworks < Room::Door
        card_name "Glassworks"
        cost generic: 2, red: 1

        class DamageChoice < Magic::Choice::Targeted
          def choices
            game.creatures.not_controlled_by(controller)
          end

          def choice_amount = 1

          def resolve!(target:)
            deal_damage(4, to: target)
          end
        end

        # "When you unlock this door, this Room deals 4 damage to target creature an opponent controls."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = DamageChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class ShatteredYard < Room::Door
        card_name "Shattered Yard"
        cost generic: 4, red: 1

        # "At the beginning of your end step, this Room deals 1 damage to each opponent."
        class EndStepTrigger < TriggeredAbility
          def should_perform?
            event.active_player == controller
          end

          def call
            game.opponents(controller).each { deal_damage(1, to: _1) }
          end
        end

        def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
      end

      doors Glassworks, ShatteredYard
    end
  end
end
