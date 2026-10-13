module Magic
  module Cards
    EnterTheEnigma = Sorcery("Enter the Enigma") do
      cost blue: 1
    end

    class EnterTheEnigma < Sorcery
      def target_choices
        battlefield.creatures
      end

      # "Target creature can't be blocked this turn. Draw a card."
      def resolve!(target:)
        give_keyword(target, :cant_be_blocked)
        draw_card

        super()
      end
    end
  end
end
