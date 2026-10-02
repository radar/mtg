module Magic
  module Cards
    SpitfireLagac = Creature("Spitfire Lagac") do
      cost generic: 3, red: 1
      creature_type("Lizard")
      power 3
      toughness 4
    end

    class SpitfireLagac < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 1) }
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
