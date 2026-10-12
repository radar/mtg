module Magic
  module Cards
    class DewdropCure < Sorcery
      card_name "Dewdrop Cure"
      cost generic: 2, white: 1
      gift :card

      def multi_target? = true

      def distinct_targets? = true

      def target_choices
        pool = controller.graveyard.creatures.select { _1.mana_value <= 2 }
        Array.new(gift_promised? ? 3 : 2) { pool }
      end

      # Return up to two target creature cards each with mana value 2 or less from your graveyard to
      # the battlefield. If the gift was promised, return up to three instead.
      def resolve!(targets:)
        targets.each do |card|
          trigger_effect(:return_target_from_graveyard_to_battlefield, target: card, controller: controller)
        end
      end
    end
  end
end
