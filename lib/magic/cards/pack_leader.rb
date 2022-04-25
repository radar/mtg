module Magic
  module Cards
    PackLeader = Creature("Pack Leader") do
      type "Creature -- Dog"
      power 2
      toughness 2
      cost generic: 1, white: 1

      def static_abilities
        [
          Abilities::Static::CreaturesGetBuffed.new(
            source: self,
            power: 1,
            toughness: 1,
            applicable_targets: -> do
              battlefield
                .creatures
                .controlled_by(controller)
                .by_type("Dog")
                .except(self)
            end
          )
        ]
      end
    end
  end
end
