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
          ActivatedAbility.new(
            costs: [Costs::Mana.new(red: 1)],
            ability: -> {
              self.modifiers << Buff.new(power: 1, until_eot: true)
            }
          )
        ]
      end
    end
  end
end
