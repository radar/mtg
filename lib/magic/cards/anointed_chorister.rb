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
          Abilities::Activated::ApplyBuff.new(
            self,
            cost: { generic: 4, white: 1 },
            power: 3,
            toughness: 3,
            until_eot: true
          )
        ]
      end
    end
  end
end
