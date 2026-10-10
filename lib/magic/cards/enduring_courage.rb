module Magic
  module Cards
    EnduringCourage = Creature("Enduring Courage") do
      cost generic: 2, red: 2
      enchantment_creature_type("Dog Glimmer")
      power 3
      toughness 3
    end

    class EnduringCourage < Creature
      # "Whenever another creature you control enters, it gets +2/+0 and gains haste until end of turn."
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:modify_power_toughness, target: event.permanent, power: 2, toughness: 0)
          trigger_effect(:grant_keyword, target: event.permanent, keyword: :haste)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }

      def death_triggers = [TriggeredAbility::EnduringReturn]
    end
  end
end
