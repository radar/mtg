module Magic
  module Cards
    SylvanMessenger = Creature("Sylvan Messenger") do
      cost generic: 3, green: 1
      creature_type "Elf"
      power 2
      toughness 2
      keywords :trample
    end

    class SylvanMessenger < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          revealed = controller.library.first(4)
          return if revealed.empty?

          actor.trigger_effect(:reveal_cards, target: revealed)

          elves, rest = revealed.partition { |card| card.type?("Elf") }
          elves.each(&:move_to_hand!)
          rest.each do |card|
            controller.library.remove(card)
            controller.library.items.push(card)
            card.zone = controller.library
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
