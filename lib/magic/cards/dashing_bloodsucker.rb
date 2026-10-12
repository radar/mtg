module Magic
  module Cards
    DashingBloodsucker = Creature("Dashing Bloodsucker") do
      cost generic: 3, black: 1
      creature_type "Vampire Warrior"
      power 2
      toughness 5
    end

    class DashingBloodsucker < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, this creature gets
      # +2/+0 and gains lifelink until end of turn."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 0, until_eot: true)
          actor.grant_keyword(Cards::Keywords::LIFELINK, until_eot: true)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
