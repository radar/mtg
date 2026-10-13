module Magic
  module Cards
    Zombify = Sorcery("Zombify") do
      cost generic: 3, black: 1
    end

    class Zombify < Sorcery
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(target:)
        reanimate target, controller: target.owner
      end
    end
  end
end
