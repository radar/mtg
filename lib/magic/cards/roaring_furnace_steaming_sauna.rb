module Magic
  module Cards
    class RoaringFurnaceSteamingSauna < Room
      class RoaringFurnace < Room::Door
        card_name "Roaring Furnace"
        cost generic: 1, red: 1

        class DamageChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures.not_controlled_by(controller)

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, damage: controller.hand.cards.count, target: target)
          end
        end

        # "When you unlock this door, this Room deals damage equal to the number of cards in your hand to target creature an
        # opponent controls."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = DamageChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class SteamingSauna < Room::Door
        card_name "Steaming Sauna"
        cost generic: 3, blue: 2

        # "You have no maximum hand size."
        def no_maximum_hand_size? = true

        # "At the beginning of your end step, draw a card."
        class EndStepTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller

          def call
            trigger_effect(:draw_card)
          end
        end

        def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
      end

      doors RoaringFurnace, SteamingSauna
    end
  end
end
