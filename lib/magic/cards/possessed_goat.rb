module Magic
  module Cards
    PossessedGoat = Creature("Possessed Goat") do
      cost white: 1
      creature_type "Goat"
      power 1
      toughness 1
    end

    class PossessedGoat < Creature
      # "{3}, Discard a card: Put three +1/+1 counters on this creature and it becomes a black Demon in addition to
      # its other colors and types. Activate only once."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}, Discard a card"

        activate_only_once

        def resolve!
          add_counter("+1/+1", to: source, amount: 3)
          source.add_types(T::Creatures["Demon"], until_eot: false)
          source.change_colors!([*source.colors, :black].uniq, until_eot: false)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
