module Magic
  module Cards
    PatientInstructor = Creature("Patient Instructor") do
      cost generic: 2, blue_or_white: 1
      creature_type("Human Citizen")
      keywords :vigilance
      power 2
      toughness 2
    end

    class PatientInstructor < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          Magic::Recruit.call(player: controller)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
