module Magic
  module Cards
    ErkenbrandLordOfWestfold = Creature("Erkenbrand, Lord of Westfold") do
      cost generic: 3, red: 1
      legendary_creature_type "Human Soldier"
      power 3
      toughness 3
    end

    class ErkenbrandLordOfWestfold < Creature
      # "Whenever Erkenbrand or another Human you control enters, creatures you control get +1/+0 until end of turn."
      # Erkenbrand is a Human, so his own entry satisfies the same check.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.type?("Human") && under_your_control?
        end

        def call
          controller.creatures.each { |creature| pump(creature, 1, 0) }
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }
    end
  end
end
