module Magic
  module Cards
    class CaretakersTalent < ClassEnchantment
      card_name "Caretaker's Talent"
      cost generic: 2, white: 1
      level_costs 2 => "{W}", 3 => "{3}{W}"

      # Whenever one or more tokens you control enter, draw a card. This ability triggers only once each turn.
      class TokenEntersTrigger < TriggeredAbility
        def should_perform?
          event.permanent.token? && event.permanent.controller == controller && !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      # Level 2: When this Class becomes level 2, create a token that's a copy of target token you control.
      class LevelTwoTrigger < TriggeredAbility
        class CopyChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).select(&:token?)

          def choice_amount = 1

          def resolve!(target:)
            Permanent.resolve(game: game, owner: controller, card: target.copiable_card, token: true, copy: true, cast: false)
          end
        end

        def should_perform? = event.permanent == actor && event.level == 2

        def call
          choice = CopyChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => TokenEntersTrigger, Events::ClassLevelGained => LevelTwoTrigger)
      end

      # Level 3: Creature tokens you control get +2/+2.
      class TokenBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2

        def applicable_targets
          return [] unless source.level >= 3

          battlefield.controlled_by(controller).creatures.select(&:token?)
        end
      end

      def static_abilities = [TokenBuff]
    end
  end
end
