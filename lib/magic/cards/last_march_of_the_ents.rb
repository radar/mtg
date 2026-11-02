module Magic
  module Cards
    LastMarchOfTheEnts = Sorcery("Last March of the Ents") do
      cost generic: 6, green: 2
      cant_be_countered
    end

    class LastMarchOfTheEnts < Sorcery
      # "Put any number of creature cards from your hand onto the battlefield." Declining puts none.
      class PutCreatures < Magic::Choice::MoveToBattlefield
        def prompt = "Put any number of creature cards from your hand onto the battlefield."

        def choices
          creatures = hand.creatures.to_a
          Magic::Targets::Choices.new(amount: 0..creatures.count, choices: creatures)
        end

        def resolve!(choices:)
          chosen = Array(choices).uniq
          invalid = chosen - hand.creatures.to_a
          raise ArgumentError, "#{invalid.first.name} is not a creature card in your hand" if invalid.any?

          chosen.each(&:resolve!)
        end

        def decline! = resolve!(choices: [])
      end

      # "Draw cards equal to the greatest toughness among creatures you control, then put any number of creature
      # cards from your hand onto the battlefield."
      def resolve!
        draw_cards(controller.creatures.map(&:toughness).max.to_i)
        game.add_choice(PutCreatures.new(actor: self))
        super
      end
    end
  end
end
