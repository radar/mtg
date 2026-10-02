module Magic
  module Cards
    IntoTheRoil = Instant("Into the Roil") do
      cost generic: 1, blue: 1
      kicker_cost generic: 1, blue: 1
    end

    class IntoTheRoil < Instant
      def target_choices
        battlefield.nonland
      end

      def resolve!(target:)
        trigger_effect(:return_to_owners_hand, target: target)
        if kicker_cost.paid?
          trigger_effect(:draw_card)
        end
      end
    end
  end
end
