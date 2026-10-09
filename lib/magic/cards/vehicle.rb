module Magic
  module Cards
    # An artifact with Crew N. It has printed power and toughness, but is a creature only while crewed (until end of
    # turn). `crew 2` in the subclass sets N.
    #
    #   class GreatGildedBoat < Vehicle
    #     power 4
    #     toughness 4
    #     crew 2
    #   end
    class Vehicle < Artifact
      TYPE_LINE = [T::Artifact, "Vehicle"].freeze
      POWER = 0
      TOUGHNESS = 0

      def self.crew(amount) = const_set(:CREW, amount)

      attr_reader :base_power, :base_toughness

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        super(**args)
      end

      def activated_abilities = [Abilities::Crew]
    end
  end
end
