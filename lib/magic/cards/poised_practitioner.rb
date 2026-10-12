module Magic
  module Cards
    PoisedPractitioner = Creature("Poised Practitioner") do
      cost generic: 2, white: 1
      creature_type("Human Monk")
      power 2
      toughness 3
    end

    class PoisedPractitioner < Creature
      class FlurryTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && second_spell_this_turn?
        end

        def call
          add_counter("+1/+1", to: actor)
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::SpellCast => FlurryTrigger }
    end
  end
end
