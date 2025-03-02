module Magic
  module Cards
    MesaEnchantress = Creature("Mesa Enchantress") do
      cost white: 2, generic: 1
      power 0
      toughness 2
      creature_type "Human Druid"
    end

    class MesaEnchantress < Creature
      class Choice < Magic::Choice::May
        def resolve!
          controller.draw!
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          game.add_choice(MesaEnchantress::Choice.new(actor: actor))
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
