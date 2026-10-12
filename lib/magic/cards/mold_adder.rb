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
            add_counter("+1/+1", to: actor)
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
