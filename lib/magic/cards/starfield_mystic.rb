module Magic
  module Cards
    StarfieldMystic = Creature("Starfield Mystic") do
      creature_type "Human Cleric"
      cost generic: 1, white: 1
      power 2
      toughness 2
    end

    class StarfieldMystic < Creature
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
          @applies_to = ->(card) { card.enchantment? }
        end
      end

      class EnchantmentGraveyardTrigger < TriggeredAbility
        def should_perform?
          event.permanent.enchantment? && event.to.graveyard? && event.permanent.controller == controller
        end

        def call
          actor.add_counter("+1/+1")
        end
      end

      def static_abilities = [ReduceManaCost]

      def event_handlers
        { Events::LeftTheBattlefield => EnchantmentGraveyardTrigger }
      end
    end
  end
end