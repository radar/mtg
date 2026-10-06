module Magic
  module Cards
    SpellgorgerWeird = Creature("Spellgorger Weird") do
      cost generic: 2, red: 1
      creature_type "Weird"
      power 2
      toughness 2
    end

    class SpellgorgerWeird < Creature
      # "Whenever you cast a noncreature spell, put a +1/+1 counter on this creature."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && !spell.creature?

        def call
          trigger_effect(:add_counter, target: actor, counter_type: "+1/+1", amount: 1)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
