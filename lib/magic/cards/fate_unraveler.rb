module Magic
  module Cards
    FateUnraveler = Creature("Fate Unraveler") do
      cost generic: 3, black: 1
      type T::Enchantment, T::Creature, "Hag"
      power 3
      toughness 4
    end

    class FateUnraveler < Creature
      # "Whenever an opponent draws a card, this creature deals 1 damage to that player."
      class CardDrawTrigger < TriggeredAbility
        def should_perform? = opponents.include?(event.player)

        def call
          actor.trigger_effect(:deal_damage, source: actor, target: event.player, damage: 1)
        end
      end

      def event_handlers = { Events::CardDraw => CardDrawTrigger }
    end
  end
end
