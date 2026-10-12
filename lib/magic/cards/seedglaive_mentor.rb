module Magic
  module Cards
    SeedglaiveMentor = Creature("Seedglaive Mentor") do
      cost "{1}{R}{W}"
      creature_type("Mouse Soldier")
      keywords :vigilance, :haste
      power 3
      toughness 2
    end

    class SeedglaiveMentor < Creature
      # Valiant -- put a +1/+1 counter on it.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
