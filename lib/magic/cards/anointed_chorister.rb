module Magic
  module Cards
    AnointedChorister = Creature("Anointed Chorister") do
      creature_type("Human Cleric")
      cost white: 1
      power 1
      toughness 1
    end

    class AnointedChorister < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 4, white: 1)]

        def resolve!
          source.modifiers << Magic::Permanents::Creature::PowerToughnessModification.new(power: 3, toughness: 3, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
