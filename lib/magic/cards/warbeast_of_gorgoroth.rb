module Magic
  module Cards
    WarbeastOfGorgoroth = Creature("Warbeast of Gorgoroth") do
      cost generic: 4, red: 1
      creature_type "Beast"
      power 5
      toughness 4
    end

    class WarbeastOfGorgoroth < Creature
      # "Whenever this creature or another creature you control with power 4 or greater dies, amass Orcs 2."
      class DiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller && event.permanent.power >= 4
        end

        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 2, subtype: "Orc")
        end
      end

      def event_handlers = { Events::CreatureDied => DiedTrigger }
    end
  end
end
