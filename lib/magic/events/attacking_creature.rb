module Magic
  module Events
    class AttackingCreature
      attr_reader :creature

      def initialize(creature:)
        @creature = creature
      end
    end
  end
end
