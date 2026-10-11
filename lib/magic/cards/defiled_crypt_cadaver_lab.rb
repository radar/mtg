module Magic
  module Cards
    class DefiledCryptCadaverLab < Room
      HorrorToken = Token.create "Horror" do
        type T::Enchantment, T::Creature, T::Creatures["Horror"]
        power 2
        toughness 2
        colors :black
      end

      class DefiledCrypt < Room::Door
        card_name "Defiled Crypt"
        cost generic: 3, black: 1

        # "Whenever one or more cards leave your graveyard, create a 2/2 black Horror enchantment creature token. This
        # ability triggers only once each turn."
        class LeavesGraveyardTrigger < TriggeredAbility
          def should_perform?
            event.from == controller.graveyard
          end

          def trigger!
            return false unless should_perform? && !actor.triggered_once_this_turn?(self.class)

            actor.trigger_once_this_turn!(self.class)
            true
          end

          def call
            trigger_effect(:create_token, token_class: HorrorToken)
          end
        end

        def event_handlers = { Events::CardLeavingZone => LeavesGraveyardTrigger }
      end

      class CadaverLab < Room::Door
        card_name "Cadaver Lab"
        cost black: 1

        class ReturnChoice < Magic::Choice::Targeted
          def prompt = "Return target creature card from your graveyard to your hand."

          def choices
            controller.graveyard.cards.select(&:creature?)
          end

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        # "When you unlock this door, return target creature card from your graveyard to your hand."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      doors DefiledCrypt, CadaverLab
    end
  end
end
