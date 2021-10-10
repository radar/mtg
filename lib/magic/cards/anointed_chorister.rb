module Magic
  module Cards
    AnointedChorister = Creature("Anointed Chorister") do
      type "Creature -- Human Cleric"
      cost white: 1
      power 1
      toughness 1
    end

    class AnointedChorister < Creature
      def activated_abilities
        [
          ActivatedAbility.new(
            mana_cost: { generic: 4, white: 1 },
            ability: -> {
              self.modifiers << Buff.new(power: 3, toughness: 3, until_eot: true)
            }
          )
        ]
      end
    end
  end
end
