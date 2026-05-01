module Magic
  module Cards
    QuirionDryad = Creature("Quirion Dryad") do
      creature_type "Elf Druid"
      cost generic: 1, green: 1
      power 1
      toughness 1
    end

    class QuirionDryad < Creature
      TRIGGERING_COLORS = [:white, :blue, :black, :red].freeze

      class SpellCastTrigger < TriggeredAbility::SpellCast
        # Whenever you cast a spell that's white, blue, black, or red, ...
        def should_perform?
          you? && (spell.colors & TRIGGERING_COLORS).any?
        end

        # ...put a +1/+1 counter on Quirion Dryad.
        def call
          actor.trigger_effect(:add_counter, counter_type: "+1/+1", target: actor)
        end
      end

      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
