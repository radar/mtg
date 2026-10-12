module Magic
  module Cards
    PactOfTheSerpent = Sorcery("Pact of the Serpent") do
      cost "{1}{B}{B}"
    end

    class PactOfTheSerpent < Sorcery
      attr_accessor :chosen_creature_type

      # "Choose a creature type." Asked as the spell resolves, then the effect is worked out from the answer.
      class TypeChoice < Magic::Choice::CreatureType
        attr_reader :target

        def prompt = "Choose a creature type. #{target.name} draws a card and loses 1 life for each creature of that type they control."

        def initialize(actor:, target:)
          @target = target
          super(actor: actor)
        end

        def resolve!(creature_type:)
          actor.chosen_creature_type = creature_type
          actor.draw_and_lose(target)
        end
      end

      def single_target?
        true
      end

      def target_choices
        game.players
      end

      # With a type already chosen (set before casting) it goes ahead at once; otherwise the player is asked.
      def resolve!(target:)
        return draw_and_lose(target) if chosen_creature_type

        game.choices.add(TypeChoice.new(actor: self, target: target))
      end

      # "Target player draws X cards and loses X life, where X is the number of creatures they control of the chosen type."
      def draw_and_lose(target)
        count = target.creatures.by_type(chosen_creature_type).count

        trigger_effect(:draw_cards, player: target, number_to_draw: count)
        trigger_effect(:lose_life, target: target, life: count)
      end
    end
  end
end
