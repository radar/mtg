module Magic
  module Cards
    class LunarConvocation < Enchantment
      card_name "Lunar Convocation"
      cost white: 1, black: 1

      # At the beginning of your end step, if you gained life this turn, each opponent loses 1 life.
      class DrainTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step? && life_gained_by(controller).positive?

        def call
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: 1) }
        end
      end

      # At the beginning of your end step, if you gained and lost life this turn, create a 1/1 black Bat creature
      # token with flying.
      class BatTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && life_gained_by(controller).positive? && game.current_turn.life_lost_by_player(controller).positive?
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Bat)
        end
      end

      # {1}{B}, Pay 2 life: Draw a card.
      class DrawAbility < Magic::ActivatedAbility
        costs "{1}{B}, Pay 2 life"

        def resolve!
          draw_card
        end
      end

      def event_handlers
        super.merge(Events::BeginningOfEndStep => [DrainTrigger, BatTrigger])
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
