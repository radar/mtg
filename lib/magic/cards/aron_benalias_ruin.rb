module Magic
  module Cards
    class AronBenaliasRuin < Creature
      card_name "Aron, Benalia's Ruin"
      type T::Super::Legendary, T::Creature, T::Creatures['Phyrexian'], T::Creatures['Human']
      cost white: 2, black: 1
      keywords :menace
      power 3
      toughness 3

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{W}{B}, {T}, Sacrifice a creature"

        def resolve!
          creatures_you_control.each do |creature|
            creature.add_counter(counter_type: Counters::Plus1Plus1)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
