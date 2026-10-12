module Magic
  module Cards
    WandertaleMentor = Creature("Wandertale Mentor") do
      cost red: 1, green: 1
      creature_type("Raccoon Bard")
      power 2
      toughness 2
    end

    class WandertaleMentor < Creature
      # Whenever you expend 4, put a +1/+1 counter on this creature.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
