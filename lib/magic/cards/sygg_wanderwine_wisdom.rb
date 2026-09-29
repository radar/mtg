module Magic
  module Cards
    class SyggWanderbrineShield < Creature
      card_name "Sygg, Wanderbrine Shield"
      legendary_creature_type "Merfolk Rogue"
      color_indicator :white
      power 2
      toughness 2

      # "Sygg can't be blocked."
      def can_be_blocked?(_) = false

      class ProtectChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        def resolve!(target:)
          target.gains_protection_from_each_color_until_turn_of!(controller)
        end
      end

      # "Whenever this creature transforms into Sygg, Wanderbrine Shield, target creature you control
      # gains protection from each color until your next turn."
      class TransformedTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          choice = ProtectChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay blue: 1
      end

      def event_handlers
        { Events::PermanentTransformed => TransformedTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class SyggWanderwineWisdom < Creature
      card_name "Sygg, Wanderwine Wisdom"
      cost generic: 1, blue: 1
      legendary_creature_type "Merfolk Wizard"
      power 2
      toughness 2
      back_face SyggWanderbrineShield

      # "Sygg can't be blocked."
      def can_be_blocked?(_) = false

      # "Whenever this creature deals combat damage to a player or planeswalker, draw a card."
      class DrawTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && (event.target.is_a?(Magic::Player) || event.target.planeswalker?)
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      class GrantChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          target.register_turn_trigger(Events::CombatDamageDealt, DrawTrigger)
        end
      end

      # "Whenever this creature enters or transforms into Sygg, Wanderwine Wisdom, target creature
      # gains 'Whenever this creature deals combat damage to a player or planeswalker, draw a card'
      # until end of turn."
      class GrantTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          choice = GrantChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = GrantTrigger.new(event:, actor:).call
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay white: 1
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::PermanentTransformed => GrantTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
