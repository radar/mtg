module Magic
  module Cards
    VerduranEnchantress = Creature("Verduran Enchantress") do
      cost green: 2, white: 1
      power 0
      toughness 2
      creature_type "Human Druid"
    end

    class VerduranEnchantress < Creature
      class Choice < Magic::Choice::May
        def resolve!
          owner.draw!
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          game.add_choice(VerduranEnchantress::Choice.new(actor: actor))
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
