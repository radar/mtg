module Magic
  module Cards
    FeatOfResistance = Instant("Feat of Resistance") do
      cost generic: 1, white: 1
    end

    class FeatOfResistance < Instant
      def target_choices
        battlefield.creatures
        target("creatures you control")
      end

      def resolve!(target:)
        target.add_counter(Counters::Plus1Plus1.new)
        game.choices.add(
          Magic::Choice::Color.new(
            callback: -> (choice)  {
              target.gains_protection_from_color(choice, until_eot: true)
            }
          )
        )
      end
    end
  end
end
