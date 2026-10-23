module Magic
  module Cards
    FangsOfKalonia = Sorcery("Fangs of Kalonia") do
      cost generic: 1, green: 1
      overload generic: 4, green: 2
    end

    class FangsOfKalonia < Sorcery
      def target_choices = controller.creatures

      # Overloaded: "each creature you control" in place of "target creature you control".
      def resolve!(target: nil, overloaded: false)
        creatures = overloaded ? controller.creatures : [target]
        creatures.each do |creature|
          add_counter "+1/+1", to: creature
          creature.add_counter("+1/+1", amount: creature.counters.of_type(Counters::Plus1Plus1).count)
        end
      end
    end
  end
end
