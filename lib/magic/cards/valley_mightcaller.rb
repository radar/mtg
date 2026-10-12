module Magic
  module Cards
    ValleyMightcaller = Creature("Valley Mightcaller") do
      cost green: 1
      creature_type("Frog Warrior")
      keywords :trample
      power 1
      toughness 1
    end

    class ValleyMightcaller < Creature
      TYPES = %w[Frog Rabbit Raccoon Squirrel].freeze

      # Whenever another Frog, Rabbit, Raccoon, or Squirrel you control enters, put a +1/+1 counter on this creature.
      class TribeEnters < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && ValleyMightcaller::TYPES.any? { event.permanent.type?(_1) }
        end

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => TribeEnters)
    end
  end
end
