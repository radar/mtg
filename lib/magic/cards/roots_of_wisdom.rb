module Magic
  module Cards
    RootsOfWisdom = Sorcery("Roots of Wisdom") do
      cost generic: 1, green: 1
    end

    class RootsOfWisdom < Sorcery
      class ReturnChoice < Magic::Choice::SearchGraveyard
        def prompt = "Return a land card or Elf card from your graveyard to your hand."

        def choices
          controller.graveyard.select { |card| card.land? || card.type?("Elf") }
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      def resolve!
        controller.mill(3)

        choice = ReturnChoice.new(actor: self)
        if choice.choices.any?
          game.choices.add(choice)
        else
          trigger_effect(:draw_card)
        end
      end
    end
  end
end
