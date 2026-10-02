module Magic
  module Cards
    RavenousGiant = Creature("Ravenous Giant") do
      cost generic: 2, red: 2
      creature_type("Giant")
      power 5
      toughness 5
    end

    class RavenousGiant < Creature
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          [controller].each { trigger_effect(:deal_damage, target: _1, damage: 1) }
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
