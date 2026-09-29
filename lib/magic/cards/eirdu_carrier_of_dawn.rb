module Magic
  module Cards
    class IsiluCarrierOfTwilight < Creature
      card_name "Isilu, Carrier of Twilight"
      legendary_creature_type "Elemental God"
      color_indicator :black
      power 5
      toughness 5
      keywords :flying, :lifelink

      # "Each other nontoken creature you control has persist."
      class GrantPersist < Abilities::Static::KeywordGrant
        keyword_grants Keywords::PERSIST

        def applicable_targets
          controller.creatures.reject(&:token?).reject { _1 == source }
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay white: 1
      end

      def static_abilities = [GrantPersist]

      def event_handlers
        { Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class EirduCarrierOfDawn < Creature
      card_name "Eirdu, Carrier of Dawn"
      cost generic: 3, white: 2
      legendary_creature_type "Elemental God"
      power 5
      toughness 5
      keywords :flying, :lifelink
      back_face IsiluCarrierOfTwilight

      # "Creature spells you cast have convoke."
      class GrantConvoke < StaticAbility
        def grants_convoke?(card, player)
          card.creature? && player == controller
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay black: 1
      end

      def static_abilities = [GrantConvoke]

      def event_handlers
        { Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
