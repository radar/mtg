module Magic
  module Cards
    AuroralProcession = Instant("Auroral Procession") do
      cost green: 1, blue: 1
    end

    class AuroralProcession < Instant
      def target_choices
        controller.graveyard.cards.to_a
      end

      def resolve!(target:)
        target.move_to_hand!
      end
    end
  end
end
