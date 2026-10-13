module Magic
  module Cards
    SpitefulVisions = Enchantment("Spiteful Visions") do
      cost "{2}{B/R}{B/R}"
    end

    class SpitefulVisions < Enchantment
      # "At the beginning of each player's draw step, that player draws an additional card."
      class DrawStepTrigger < TriggeredAbility
        def call
          event.player.draw!
        end
      end

      # "Whenever a player draws a card, this enchantment deals 1 damage to that player."
      class CardDrawTrigger < TriggeredAbility
        def call
          deal_damage 1, to: event.player
        end
      end

      def event_handlers = { Events::DrawStep => DrawStepTrigger, Events::CardDraw => CardDrawTrigger }
    end
  end
end
