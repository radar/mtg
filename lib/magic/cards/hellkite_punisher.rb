module Magic
  module Cards
    HellkitePunisher = Creature("Hellkite Punisher") do
      type "Creature -- Dragon"
      power 6
      toughness 6

      keywords :flying
    end

    class HellkitePunisher < Creature
      def activated_abilities
        [
          Abilities::Activated::ApplyBuff.new(self, cost: { red: 1}, power: 1, toughness: 0, until_eot: true)
        ]
      end
    end
  end
end
