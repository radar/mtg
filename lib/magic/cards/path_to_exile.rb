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
        choice = Magic::Choice::SearchLibrary.new(
          actor: target.card,
          to_zone: :battlefield,
          enters_tapped: true,
          filter: Filter[:basic_lands],
        )
        target.game.add_choice(choice) if controller.library.basic_lands.any?
      end
    end
  end
end