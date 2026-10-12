module Magic
  module Cards
    TheSackvilleBagginses = Creature("The Sackville-Bagginses") do
      cost generic: 1, black: 1
      legendary_creature_type "Halfling Citizen"
      power 2
      toughness 2
    end

    class TheSackvilleBagginses < Creature
      # "When The Sackville-Bagginses enter, you may sacrifice another creature or artifact. If you do, draw a card and
      # create a Treasure token."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def candidates
          controller.permanents.select { (_1.creature? || _1.artifact?) && _1 != actor }
        end

        def resolve!(sacrifice: nil)
          super
          trigger_effect(:draw_cards, number_to_draw: 1)
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: controller)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = SacrificeChoice.new(actor: actor)
          game.choices.add(choice) if choice.candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever you sacrifice a token, target opponent loses 1 life."
      class LoseLifeChoice < Magic::Choice::Targeted
        def choices = game.opponents(controller)

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:lose_life, target: target, life: 1)
        end
      end

      class TokenSacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent.token? && event.permanent.controller == controller
        end

        def call
          game.add_choice(LoseLifeChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::PermanentSacrificed => TokenSacrificedTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
