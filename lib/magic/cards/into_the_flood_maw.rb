module Magic
  module Cards
    class IntoTheFloodMaw < Instant
      card_name "Into the Flood Maw"
      cost blue: 1
      gift :tapped_fish

      # Return target creature an opponent controls to its owner's hand. If the gift was promised,
      # instead return target nonland permanent an opponent controls to its owner's hand.
      def target_choices
        permanents = battlefield.not_controlled_by(controller)
        gift_promised? ? permanents.reject(&:land?) : permanents.creatures
      end

      def resolve!(target:)
        bounce(target)
      end
    end
  end
end
