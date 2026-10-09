module Magic
  module Cards
    GatheringOfDarkness = Sorcery("Gathering of Darkness") do
      cost generic: 3, black: 1
    end

    class GatheringOfDarkness < Sorcery
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(target: nil)
        target&.move_to_hand!
        Magic::Amass.call(source: self, controller: controller, amount: 3)
      end
    end
  end
end
