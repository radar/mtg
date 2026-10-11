module Magic
  module Cards
    class SmokyLoungeMistySalon < Room
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        colors :blue
        keywords :flying
        power 0
        toughness 0
      end

      class SmokyLounge < Room::Door
        card_name "Smoky Lounge"
        cost generic: 2, red: 1

        # "At the beginning of your first main phase, add {R}{R}. Spend this mana only to cast Room spells and unlock doors."
        class FirstMainTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller

          def call
            controller.add_mana({ red: 2 }, restriction: ManaRestriction::RoomSpellOrUnlock.new)
          end
        end

        def event_handlers = { Events::FirstMainPhase => FirstMainTrigger }
      end

      class MistySalon < Room::Door
        card_name "Misty Salon"
        cost generic: 3, blue: 1

        # "When you unlock this door, create an X/X blue Spirit creature token with flying, where X is the number of
        # unlocked doors among Rooms you control."
        when_unlocked do
          x = controller.unlocked_doors.size
          trigger_effect(:create_token, token_class: SmokyLoungeMistySalon::SpiritToken, base_power: x, base_toughness: x)
        end
      end

      doors SmokyLounge, MistySalon
    end
  end
end
