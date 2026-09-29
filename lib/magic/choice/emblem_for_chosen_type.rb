module Magic
  class Choice
    # "Choose a creature type. You get an emblem ...": answered with `creature_type:`, then the
    # controller gets `emblem_class.new(game:, owner:, creature_type:)`.
    class EmblemForChosenType < CreatureType
      def initialize(actor:, emblem_class:)
        super(actor:)
        @emblem_class = emblem_class
      end

      def resolve!(creature_type:)
        game.add_emblem(@emblem_class.new(game:, owner: controller, creature_type:))
      end
    end
  end
end
