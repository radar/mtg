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
        trigger_effect(:grant_keyword, target: target, keyword: :cant_be_blocked)
        trigger_effect(:draw_card)

        super()
      end
    end
  end
end
