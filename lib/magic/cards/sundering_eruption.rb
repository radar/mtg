module Magic
  module Cards
    # The land back face of Sundering Eruption. It has no mana cost.
    VolcanicFissure = Card("Volcanic Fissure") do
      type "Land"
    end

    class VolcanicFissure < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end

    SunderingEruption = Sorcery("Sundering Eruption") do
      cost generic: 2, red: 1
      back_face VolcanicFissure
    end

    class SunderingEruption < Sorcery
      def target_choices = battlefield.lands

      # "Destroy target land. Its controller may search their library for a basic land card, put it onto the
      # battlefield tapped, then shuffle. Creatures without flying can't block this turn."
      def resolve!(target:)
        land_controller = target.controller
        destroy(target)
        # The destroyed land is the actor, so the search runs in its controller's library.
        game.search_library(target, find: :basic_lands, to: :battlefield, tapped: true) if land_controller.library.basic_lands.any?
        battlefield.creatures.reject(&:flying?).each(&:prevent_blocking!)
      end
    end
  end
end
