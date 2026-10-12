module Magic
  module Cards
    GarruksUprising = Enchantment("Garruk's Uprising") do
      cost generic: 2, green: 1
    end

    class GarruksUprising < Enchantment
      # "When this enchantment enters, if you control a creature with power 4 or greater, draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = controller.creatures.any? { |creature| creature.power >= 4 }

        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Creatures you control have trample."
      class TrampleGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applicable_targets { your.creatures }
      end

      def static_abilities = [TrampleGrant]

      # "Whenever a creature you control with power 4 or greater enters, draw a card."
      class CreatureEntersTrigger < TriggeredAbility
        def should_perform?
          permanent = event.permanent
          permanent.creature? && permanent.controller == controller && permanent.power >= 4
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
