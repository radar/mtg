module Magic
  module Cards
    class PathToExile < Instant
      card_name "Path to Exile"
      cost white: 1

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        controller = target.controller
        trigger_effect(:exile, target: target)
        # The permanent, not its card, is the actor: a token's card has no controller.
        target.game.search_library(target, find: :basic_lands, to: :battlefield, tapped: true) if controller.library.basic_lands.any?
      end
    end
  end
end