module Magic
  module Cards
    DevilishValet = Creature("Devilish Valet") do
      cost generic: 2, red: 1
      creature_type "Devil Warrior"
      power 1
      toughness 3
      keywords :trample, :haste
    end

    class DevilishValet < Creature
      class AllianceTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          actor.trigger_effect(:modify_power_toughness, power: actor.power, target: actor, until_eot: true)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => AllianceTrigger
        }
      end
    end
  end
end
