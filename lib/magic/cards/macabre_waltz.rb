module Magic
  module Cards
    MacabreWaltz = Sorcery("Macabre Waltz") do
      cost generic: 1, black: 1
    end

    class MacabreWaltz < Sorcery
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(targets:)
        targets.uniq.each { _1.move_to_hand! }
        game.choices.add(Magic::Choice::Discard.new(actor: self, player: controller))
      end
    end
  end
end
