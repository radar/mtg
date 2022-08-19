module Magic
  module Cards
    AnointedChorister = Creature("Anointed Chorister") do
      type "Creature -- Human Cleric"
      cost white: 1
      power 1
      toughness 1
    end

    class AnointedChorister < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        attr_reader :source

        def initialize(**args)
          super(**args, costs: [Costs::Mana.new(generic: 4, white: 1)])
        end

        def resolve!
          source.modifiers << Magic::Permanents::Creature::Buff.new(power: 3, toughness: 3, until_eot: true)
        end
      end
    end
  end
end
