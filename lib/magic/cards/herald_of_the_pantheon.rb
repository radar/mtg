module Magic
  module Cards
    HeraldOfThePantheon = Creature("Herald of the Pantheon") do
      cost generic: 1, green: 1
      creature_type "Centaur Shaman"
      power 2
      toughness 2

    end

    class HeraldOfThePantheon < Creature
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
          @applies_to = -> (c) { c.enchantment? }
        end
      end

      def static_abilities
        [ReduceManaCost]
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          actor.trigger_effect(:gain_life)
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
