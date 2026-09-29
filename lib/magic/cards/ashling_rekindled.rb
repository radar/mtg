module Magic
  module Cards
    class AshlingRimebound < Creature
      card_name "Ashling, Rimebound"
      legendary_creature_type "Elemental Wizard"
      color_indicator :blue
      power 1
      toughness 3

      class ColorChoice < Magic::Choice::Color
        def resolve!(color:)
          controller.add_mana({ color => 2 }, restriction: ManaRestriction::MinimumManaValue.new(4))
        end
      end

      # "Whenever this creature transforms into Ashling, Rimebound and at the beginning of your
      # first main phase, add two mana of any one color. Spend this mana only to cast spells with
      # mana value 4 or greater."
      class AddManaTrigger < TriggeredAbility
        def should_perform?
          event.respond_to?(:active_player) ? event.active_player == controller : event.permanent == actor
        end

        def call
          game.choices.add(ColorChoice.new(actor:))
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay red: 1
      end

      def event_handlers
        {
          Events::PermanentTransformed => AddManaTrigger,
          Events::FirstMainPhase => [AddManaTrigger, PayToTransformTrigger]
        }
      end
    end

    class AshlingRekindled < Creature
      card_name "Ashling, Rekindled"
      cost generic: 1, red: 1
      legendary_creature_type "Elemental Sorcerer"
      power 1
      toughness 3
      back_face AshlingRimebound

      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card:)
          super
          trigger_effect(:draw_card)
        end
      end

      class MayDiscardChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DiscardChoice.new(actor:, player: controller)) if hand.any?
        end
      end

      # "Whenever this creature enters or transforms into Ashling, Rekindled, you may discard a
      # card. If you do, draw a card."
      class LootTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          game.choices.add(MayDiscardChoice.new(actor:))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = LootTrigger.new(event:, actor:).call
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay blue: 1
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::PermanentTransformed => LootTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
