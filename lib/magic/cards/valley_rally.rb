module Magic
  module Cards
    class ValleyRally < Instant
      card_name "Valley Rally"
      cost generic: 2, red: 1
      gift :food

      def multi_target? = gift_promised?

      def target_choices
        creatures = battlefield.controlled_by(controller).creatures
        gift_promised? ? [creatures] : []
      end

      # Creatures you control get +2/+0 until end of turn. If the gift was promised, target creature
      # you control gains first strike until end of turn.
      def resolve!(targets: [])
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 2, 0)
        end
        give_keyword(targets.first, :first_strike) if gift_promised? && targets.first
      end
    end
  end
end
