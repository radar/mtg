module Magic
  module Cards
    BurlfistOak = Creature("Burlfist Oak") do
      cost generic: 2, green: 2
      creature_type "Treefolk"
      power 2
      toughness 3
    end

    class BurlfistOak < Creature
      # "Whenever you draw a card, this creature gets +2/+2 until end of turn."
      class DrawTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 2)
        end
      end

      def event_handlers = { Events::CardDraw => DrawTrigger }
    end
  end
end
