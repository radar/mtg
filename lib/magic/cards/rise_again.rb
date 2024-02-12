module Magic
  module Cards
    RiseAgain = Sorcery("Rise Again") do
      cost black: 1, generic: 4
    end

    class RiseAgain < Sorcery
      def target_choices
        controller.graveyard.cards
      end

      def single_target?
        true
      end

      def resolve!(target:)
        trigger_effect(:return_target_from_graveyard_to_battlefield, target: target)
      end
    end
  end
end
