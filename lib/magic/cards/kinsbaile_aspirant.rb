module Magic
  module Cards
    KinsbaileAspirant = Creature("Kinsbaile Aspirant") do
      cost white: 1
      creature_type("Kithkin Citizen")
      power 2
      toughness 1
    end

    class KinsbaileAspirant < Creature
      # As an additional cost to cast this spell, behold a Kithkin or pay {2}.
      def additional_costs
        [Costs::Behold.new(self, type: "Kithkin", or_mana: { generic: 2 })]
      end

      # Whenever another creature you control enters, this creature gets +1/+1 until end of turn.
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 1, until_eot: true)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
