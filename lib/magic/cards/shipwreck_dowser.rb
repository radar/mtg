module Magic
  module Cards
    class ShipwreckDowser < Creature
      card_name "Shipwreck Dowser"
      cost generic: 3, blue: 2
      creature_type "Merfolk Wizard"

      keywords :prowess

      def target_choices
        controller.graveyard.by_any_type(T::Instant, T::Sorcery)
      end

      def resolve!(target:)
        trigger_effect(:move_card_zone, from: target.zone, target: target, to: controller.hand)
      end
    end
  end
end
