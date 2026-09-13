module Magic
  module Cards
    FieryInscription = Enchantment("Fiery Inscription") do
      cost generic: 2, red: 1

      enters_the_battlefield do
        game.the_ring_tempts!(actor.controller)
      end
    end

    class FieryInscription < Enchantment
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?)
        end

        def call
          opponents.each do |opponent|
            trigger_effect(:deal_damage, target: opponent, damage: 2)
          end
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
