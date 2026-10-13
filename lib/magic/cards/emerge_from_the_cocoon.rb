module Magic
  module Cards
    EmergeFromTheCocoon = Sorcery("Emerge from the Cocoon") do
      cost generic: 4, white: 1
    end

    class EmergeFromTheCocoon < Sorcery
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(target:)
        reanimate target, controller: target.owner
        gain_life(3)
      end
    end
  end
end
