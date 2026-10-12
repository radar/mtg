module Magic
  module Cards
    TempestAngler = Creature("Tempest Angler") do
      cost generic: 1, blue_or_red: 2
      creature_type("Otter Wizard")
      power 2
      toughness 2
    end

    class TempestAngler < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => SpellCastTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
