module Magic
  module Cards
    Unsummon = Instant("Unsummon") do
      cost blue: 1
    end

    class Unsummon < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:return_to_owners_hand, target: target)
      end
    end
  end
end
