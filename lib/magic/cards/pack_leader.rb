module Magic
  module Cards
    PackLeader = Creature("Pack Leader") do
      type "Creature -- Dog"
      power 2
      toughness 2
      cost generic: 1, white: 1

      class CreaturesGetBuffed < Abilities::Static::CreaturesGetBuffed
        def initialize(source:)
          @source = source
        end

        def power
          1
        end

        def toughness
          1
        end

        def applicable_targets
          source.controller.creatures.by_any_type("Dog")
        end
      end

      def static_abilities = [CreaturesGetBuffed]
    end
  end
end
