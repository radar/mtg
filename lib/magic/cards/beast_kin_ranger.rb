module Magic
  module Cards
    BeastKinRanger = Creature("Beast-Kin Ranger") do
      cost generic: 2, green: 1
      creature_type("Elf Ranger")
      keywords :trample
      power 3
      toughness 3
    end

    class BeastKinRanger < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          pump(actor, 1, 0)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
