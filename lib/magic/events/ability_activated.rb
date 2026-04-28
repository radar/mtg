# frozen_string_literal: true

module Magic
  module Events
    class AbilityActivated
      attr_reader :ability, :player, :targets

      def initialize(ability:, player:, targets: [])
        @ability = ability
        @player = player
        @targets = targets
      end
    end
  end
end
