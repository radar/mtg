module Magic
  module Cards
    MindlessConscription = Enchantment("Mindless Conscription") do
      cost generic: 2, black: 1
    end

    class MindlessConscription < Enchantment
      # "When this enchantment enters and whenever you draw your third card each turn, amass Zombies 3."
      class AmassTrigger < TriggeredAbility
        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 3, subtype: "Zombie")
        end
      end

      class EntersTrigger < AmassTrigger
      end

      class ThirdCardDrawTrigger < AmassTrigger
        def should_perform?
          you? &&
            game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 3
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::CardDraw => ThirdCardDrawTrigger }
    end
  end
end
