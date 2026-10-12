module Magic
  module Events
    # A Class enchantment became `level` ("When this Class becomes level 2").
    class ClassLevelGained
      attr_reader :permanent, :level

      def initialize(permanent:, level:)
        @permanent = permanent
        @level = level
      end
    end
  end
end
