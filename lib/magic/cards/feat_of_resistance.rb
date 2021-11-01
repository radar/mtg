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
        target.add_counter(power: 1, toughness: 1)
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
