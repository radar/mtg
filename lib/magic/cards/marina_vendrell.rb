module Magic
  module Cards
    MarinaVendrell = Creature("Marina Vendrell") do
      cost white: 1, blue: 1, black: 1, red: 1, green: 1
      legendary_creature_type "Human Warlock"
      power 3
      toughness 5
    end

    class MarinaVendrell < Creature
      # "When Marina Vendrell enters, reveal the top seven cards of your library. Put all enchantment cards from among
      # them into your hand and the rest on the bottom of your library in a random order."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          library = controller.library
          revealed = library.first(7)
          reveal_cards(revealed)
          enchantments, rest = revealed.partition(&:enchantment?)
          enchantments.each(&:move_to_hand!)
          rest.shuffle.each do |card|
            library.remove(card)
            library.push(card)
          end
        end
      end

      # "{T}: Lock or unlock a door of target Room you control. Activate only as a sorcery." The Room is chosen as the
      # ability resolves.
      class LockOrUnlockDoor < Magic::ActivatedAbility
        costs "{T}"

        def requirements_met?
          game.can_cast_sorcery?(controller)
        end

        def resolve!
          choice = Magic::Choice::LockOrUnlockDoor.new(actor: source)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [LockOrUnlockDoor]
    end
  end
end
