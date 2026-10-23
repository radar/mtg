module Magic
  module Cards
    FlareOfMalice = Instant("Flare of Malice") do
      cost generic: 2, black: 2
    end

    class FlareOfMalice < Instant
      # "You may sacrifice a nontoken black creature rather than pay this spell's mana cost."
      def alternative_cost = Costs::SacrificeCreatureAlternativeCost.new(color: :black)

      # The permanents an opponent may sacrifice: those among their creatures and planeswalkers with the greatest mana value.
      class SacrificeChoice < Magic::Choice
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        def chooser = player

        def prompt = "Sacrifice a creature or planeswalker with the greatest mana value among them."

        def choices
          candidates = player.permanents.select { _1.creature? || _1.planeswalker? }
          greatest = candidates.map(&:mana_value).max
          candidates.select { _1.mana_value == greatest }
        end

        def resolve!(sacrifice:)
          raise ArgumentError, "choose one of #{choices.map(&:name).join(", ")}" unless choices.include?(sacrifice)

          sacrifice.sacrifice!
        end
      end

      # "Each opponent sacrifices a creature or planeswalker with the greatest mana value among creatures and
      # planeswalkers they control."
      def resolve!
        game.opponents(controller).each do |opponent|
          choice = SacrificeChoice.new(actor: self, player: opponent)
          options = choice.choices
          if options.size == 1
            options.first.sacrifice!
          elsif options.any?
            game.add_choice(choice)
          end
        end
      end
    end
  end
end
