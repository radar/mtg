module Magic
  module Cards
    MoldAdder = Creature("Mold Adder") do
      cost green: 1
      creature_type("Fungus Snake")
      power 1
      toughness 1
    end

    class MoldAdder < Creature
      class OpponentSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponent? && (spell.colors.include?(:blue) || spell.colors.include?(:black))
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => OpponentSpellCastTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
