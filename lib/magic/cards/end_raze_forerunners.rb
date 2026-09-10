module Magic
  module Cards
    EndRazeForerunners = Creature("End-Raze Forerunners") do
      cost generic: 5, green: 3
      creature_type "Boar"
      power 7
      toughness 7
      keywords :vigilance, :trample, :haste
    end

    class EndRazeForerunners < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          other_creatures_you_control.each do |creature|
            actor.trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: creature, until_eot: true)
            creature.grant_keyword(Cards::Keywords::VIGILANCE, until_eot: true)
            creature.grant_keyword(Cards::Keywords::TRAMPLE, until_eot: true)
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
