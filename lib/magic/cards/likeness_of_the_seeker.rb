module Magic
  module Cards
    LikenessOfTheSeeker = Creature("Likeness of the Seeker") do
      enchantment_creature_type "Human Monk"
      cost generic: 1, green: 1
      power 3
      toughness 3
    end

    class LikenessOfTheSeeker < Creature
      class BlockedTrigger < TriggeredAbility
        def should_perform?
          event.attacker == actor
        end

        def call
          controller.lands.first(3).each(&:untap!)
        end
      end

      def event_handlers
        { Events::CreatureBlocked => BlockedTrigger }
      end
    end
  end
end