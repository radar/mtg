module Magic
  module Cards
    PollywogProdigy = Creature("Pollywog Prodigy") do
      cost generic: 1, blue: 1
      creature_type "Frog Wizard"
      power 1
      toughness 3
    end

    class PollywogProdigy < Creature
      # Evolve: "Whenever a creature you control enters, if that creature has greater power or toughness than this
      # creature, put a +1/+1 counter on this creature."
      class EvolveTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? &&
            (event.permanent.power > actor.power || event.permanent.toughness > actor.toughness)
        end

        def call
          trigger_effect(:add_counter, target: actor, counter_type: "+1/+1", amount: 1)
        end
      end

      # "Whenever an opponent casts a noncreature spell with mana value less than this creature's power, draw a card."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player != controller && !spell.type?("Creature") && spell.mana_value < actor.power
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => EvolveTrigger, Events::SpellCast => SpellCastTrigger)
      end
    end
  end
end
