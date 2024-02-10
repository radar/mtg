module Magic
  module Cards
    BasrisSolidarity = Sorcery("Basri's Solidarity") do
      cost generic: 1, white: 1
    end

    class BasrisSolidarity < Sorcery
      def resolve!
        controller.creatures.each do |creature|
          creature.add_counter(counter_type: Counters::Plus1Plus1)
        end

        super
      end
    end
  end
end
