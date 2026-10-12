module Magic
  module Cards
    class SazacapsBrew < Instant
      card_name "Sazacap's Brew"
      cost generic: 1, red: 1
      gift :tapped_fish

      # As an additional cost to cast this spell, discard a card.
      def additional_costs
        [Costs::Discard.new(controller)]
      end

      def multi_target? = true

      def target_choices
        pools = [game.players]
        pools << battlefield.controlled_by(controller).creatures if gift_promised?
        pools
      end

      # Target player draws two cards. If the gift was promised, target creature you control gets +2/+0
      # until end of turn.
      def resolve!(targets:)
        trigger_effect(:draw_cards, player: targets.first, number_to_draw: 2)
        trigger_effect(:modify_power_toughness, power: 2, toughness: 0, target: targets[1], until_eot: true) if gift_promised?
      end
    end
  end
end
