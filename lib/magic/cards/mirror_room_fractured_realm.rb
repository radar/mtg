module Magic
  module Cards
    class MirrorRoomFracturedRealm < Room
      class MirrorRoom < Room::Door
        card_name "Mirror Room"
        cost generic: 2, blue: 1

        class CopyChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures.controlled_by(controller)

          def choice_amount = 1

          def resolve!(target:)
            [*trigger_effect(:create_token_copy, card: target.copiable_card)].each do |token|
              token.add_types(T::Creatures["Reflection"], until_eot: false)
            end
          end
        end

        # "When you unlock this door, create a token that's a copy of target creature you control, except it's a Reflection in
        # addition to its other creature types."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = CopyChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class FracturedRealm < Room::Door
        card_name "Fractured Realm"
        cost generic: 5, blue: 2

        # "If a triggered ability of a permanent you control triggers, that ability triggers an additional time."
        class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
          def doubles_trigger_for?(permanent, _event)
            permanent.controller == controller
          end
        end

        def static_abilities = [TriggersAdditionalTime]
      end

      doors MirrorRoom, FracturedRealm
    end
  end
end
