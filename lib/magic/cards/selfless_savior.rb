module Magic
  module Cards
    SelflessSavior = Creature("Selfless Savior") do
      power 1
      toughness 1
      cost white: 1
      type "Creature -- Dog"
    end

    class SelflessSavior < Creature
      def activated_abilities
        [
          ActivatedAbility.new(
            costs: [Costs::Sacrifice.new(self)],
            ability: -> (targets:) {
              targets.first.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
            },

          )
        ]
      end
    end
  end
end
