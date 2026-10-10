module Magic
  module Cards
    # An artifact with Station. Each `station_level` is a "N+ | ..." line: its abilities apply only while the permanent
    # has at least N charge counters (`Permanent#station_levels_reached`). `becomes_creature_at` is the final level's
    # "It's an artifact creature at N+", using the card's printed power and toughness.
    #
    #   class ExplorationBroodship < Spacecraft
    #     power 4
    #     toughness 4
    #     station_level 3, additional_lands: 1
    #     station_level 8, static_abilities: [FlyingGrant]
    #     becomes_creature_at 8
    #   end
    class Spacecraft < Artifact
      TYPE_LINE = [T::Artifact, "Spacecraft"].freeze
      POWER = 0
      TOUGHNESS = 0

      StationLevel = Data.define(:threshold, :additional_lands, :static_abilities)

      attr_reader :base_power, :base_toughness

      class << self
        def station_levels = (@station_levels ||= [])

        def station_level(threshold, additional_lands: 0, static_abilities: [])
          station_levels << StationLevel.new(threshold:, additional_lands:, static_abilities:)
        end

        def becomes_creature_at(threshold)
          define_method(:station_creature_threshold) { threshold }
        end
      end

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        super(**args)
      end

      def station_levels = self.class.station_levels

      def station_creature_threshold = nil

      def activated_abilities = [Abilities::Station]
    end
  end
end
