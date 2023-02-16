module Magic
  module Cards
    VrynWingmare = Creature("Vryn Wingmare") do
      creature_type("Pegasus")
      cost white: 1, generic: 2
      power 2
      toughness 1

      class IncreaseManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: 1 }
          @applies_to = -> (c) { !c.creature? }
        end
      end

      def static_abilities = [IncreaseManaCost]
    end
  end
end
