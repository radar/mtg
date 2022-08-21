module Magic
  module Cards
    FoundryInspector = Creature("Foundry Inspector") do
      cost generic: 3
      type "Artifact Creature -- Constructor"
      power 3
      toughness 2

      class ReduceManaCost < Abilities::Static::ReduceManaCost
        def initialize(source:)
          @source = source
          @reduction = { generic: 1 }
          @applies_to = -> (c) { c.artifact? }
        end
      end

      def static_abilities = [ReduceManaCost]
    end
  end
end
