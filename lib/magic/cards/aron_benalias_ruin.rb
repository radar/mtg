module Magic
  module Cards
    AronBenaliasRuin = Creature("Aron, Benalia's Ruin") do
      type "Legendary Creature -- Phyrexian Human"
      cost white: 2, black: 1
      keywords :menace
      power 3
      toughness 3
    end

    class AronBenaliasRuin < Creature

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{W}{B}, {T}, Sacrifice a creature"

        def resolve!
          creatures.controlled_by(source.controller).each do |creature|
            creature.add_counter(Counters::Plus1Plus1)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
