module Magic
  module Cards
    ViciousClown = Creature("Vicious Clown") do
      cost generic: 2, red: 1
      creature_type "Human Clown"
      power 2
      toughness 3
    end

    class ViciousClown < Creature
      # "Whenever another creature you control with power 2 or less enters, this creature gets +2/+0 until end of
      # turn."
      class EntersTrigger < TriggeredAbility
        def should_perform?
          permanent = event.permanent
          permanent != actor && permanent.creature? && permanent.controller == controller && permanent.power <= 2
        end

        def call
          pump(actor, 2, 0)
        end
      end

      def event_handlers
        super.merge({ Events::EnteredTheBattlefield => EntersTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
