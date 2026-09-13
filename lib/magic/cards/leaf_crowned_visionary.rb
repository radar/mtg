module Magic
  module Cards
    class LeafCrownedVisionary < Creature
      card_name "Leaf-Crowned Visionary"
      cost "{G}{G}"
      creature_type "Elf Druid"
      power 1
      toughness 1

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        applicable_targets { your.creatures.all("Elf").except(source) }
      end

      class MayPayChoice < Magic::Choice::May
        def resolve!(payment: {})
          controller.pay_mana(payment)
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def static_abilities = [PowerAndToughnessModification]

      class SpellCastTrigger < TriggeredAbility::SpellCast
        # Whenever you cast an Elf spell, ...
        def should_perform?
          spell.type?("Elf") && you?
        end

        # you may pay {G}. If you do, draw a card.
        def call
          game.choices.add(MayPayChoice.new(actor: actor))
        end
      end

      # Whenever you cast an Elf spell,
      # you may pay {G}. If you do, draw a card.
      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
