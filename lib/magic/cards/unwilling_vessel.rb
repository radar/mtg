module Magic
  module Cards
    UnwillingVessel = Creature("Unwilling Vessel") do
      cost generic: 2, blue: 1
      creature_type "Human Wizard"
      keywords :vigilance
      power 3
      toughness 2
    end

    class UnwillingVessel < Creature
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        colors :blue
        keywords :flying
        power 0
        toughness 0
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, put a possession
      # counter on this creature."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          add_counter("possession")
        end
      end

      # "When this creature dies, create an X/X blue Spirit creature token with flying, where X is the number of counters
      # on this creature."
      class DiesTrigger < TriggeredAbility::Death
        def call
          x = actor.counters.count
          trigger_effect(:create_token, token_class: SpiritToken, base_power: x, base_toughness: x)
        end
      end

      def event_handlers = EerieTrigger.handlers
      def death_triggers = [DiesTrigger]
    end
  end
end
