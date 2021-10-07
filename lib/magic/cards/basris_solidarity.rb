module Magic
  module Cards
    BasrisSolidarity = Card("Basri's Solidarity") do
      type "Sorcery"
      cost generic: 1, white: 1
    end

    class BasrisSolidarity < Card
      def resolve!
        creatures = game.battlefield.creatures.controlled_by(controller)
        creatures.each do |creature|
          creature.add_counter(power: 1, toughness: 1)
        end

        super
      end
    end
  end
end
