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
          pump(actor, 2, 0)
          actor.grant_keyword(Cards::Keywords::LIFELINK, until_eot: true)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
