module Magic
  module Cards
    class ProtectiveResponse < Instant
      card_name "Protective Response"
      cost generic: 2, white: 1
      convoke

      # "Destroy target attacking or blocking creature."
      def target_choices
        battlefield.creatures.select { current_turn.attacking?(_1) || current_turn.blocking?(_1) }
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target:)
      end
    end
  end
end
