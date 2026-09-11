module Magic
  module Cards
    class Mirrorform < Instant
      card_name "Mirrorform"
      cost generic: 4, blue: 2

      def target_choices
        battlefield.permanents.reject { |permanent| permanent.card.is_a?(Aura) }
      end

      def resolve!(target:)
        controller.permanents.nonland.each do |permanent|
          permanent.copied_card = target.copiable_card
        end
      end
    end
  end
end
