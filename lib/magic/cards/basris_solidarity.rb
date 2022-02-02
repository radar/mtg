module Magic
  module Cards
    BasrisSolidarity = Card("Basri's Solidarity") do
      type "Sorcery"
      cost generic: 1, white: 1
    end

    class BasrisSolidarity < Card
      def resolve!
        creatures = battlefield.creatures.controlled_by(controller)
        creatures.each do |creature|
          creature.add_counter(Counters::Plus1Plus1)
        end

        super
      end
    end
  end
end
