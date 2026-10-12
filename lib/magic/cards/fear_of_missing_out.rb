module Magic
  module Cards
    FearOfMissingOut = Creature("Fear of Missing Out") do
      cost generic: 1, red: 1
      enchantment_creature_type("Nightmare")
      power 2
      toughness 3
    end

    class FearOfMissingOut < Creature
      # "When this creature enters, discard a card, then draw a card."
      class DiscardThenDraw < Magic::Choice::Discard
        def resolve!(**)
          super
          trigger_effect(:draw_cards, player: player, number_to_draw: 1)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          if controller.hand.any?
            game.choices.add(DiscardThenDraw.new(player: controller, actor: actor))
          else
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Delirium — Whenever this creature attacks for the first time each turn, if there are four or more card types
      # among cards in your graveyard, untap target creature. After this phase, there is an additional combat phase."
      class AttacksTrigger < TriggeredAbility
        class UntapChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            target.untap!
          end
        end

        def first_attack_this_turn?
          game.current_turn.events.count { _1.is_a?(Events::AttackDeclared) && _1.attack.attacker == actor } <= 1
        end

        def should_perform?
          event.attack.attacker == actor && first_attack_this_turn? && controller.graveyard.delirium?
        end

        def call
          game.current_turn.queue_additional_combat!
          game.add_choice(UntapChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::AttackDeclared => AttacksTrigger }
    end
  end
end
