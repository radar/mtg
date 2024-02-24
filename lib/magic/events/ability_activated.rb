module Magic
  module Events
    class AbilityActivated
      attr_reader :ability, :player

      def initialize(ability:, player:)
        @ability = ability
        @player = player
      end
    end
  end
end
