module Magic
  module Cards
    class BottomlessPoolLockerRoom < Room
      class BottomlessPool < Room::Door
        card_name "Bottomless Pool"
        cost blue: 1

        class BounceChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
          end
        end

        # "When you unlock this door, return up to one target creature to its owner's hand."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = BounceChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class LockerRoom < Room::Door
        card_name "Locker Room"
        cost generic: 4, blue: 1

        # "Whenever one or more creatures you control deal combat damage to a player, draw a card." One card per combat
        # damage step however many creatures deal damage in it.
        class DrawTrigger < TriggeredAbility
          def should_perform?
            event.combat? && event.target.player? && event.source.respond_to?(:controller) &&
              event.source.controller == controller && !already_triggered_this_step?
          end

          def call
            actor.state[:locker_room_step] = step_key
            trigger_effect(:draw_card)
          end

          private

          def step_key = [game.current_turn.number, game.current_turn.step]

          def already_triggered_this_step?
            actor.state[:locker_room_step] == step_key
          end
        end

        def event_handlers = { Events::DamageDealt => DrawTrigger }
      end

      doors BottomlessPool, LockerRoom
    end
  end
end
