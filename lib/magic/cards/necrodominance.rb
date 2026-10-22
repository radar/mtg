module Magic
  module Cards
    Necrodominance = Enchantment("Necrodominance") do
      type T::Super::Legendary, T::Enchantment
      cost black: 3
    end

    class Necrodominance < Enchantment
      # Skip your draw step.
      def skips_draw_step? = true

      # Your maximum hand size is five.
      def fixed_maximum_hand_size = 5

      # At the beginning of your end step, you may pay any amount of life. If you do, draw that many cards.
      class PayLifeChoice < Magic::Choice::May
        # Pay `life`, then draw that many cards. You can't pay more life than you have (CR 119.4), so that does nothing.
        def resolve!(life: 0)
          return unless life.positive? && life <= controller.life

          lose_life controller, life
          draw_cards life
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step?

        def call
          game.choices.add(PayLifeChoice.new(actor: actor))
        end
      end

      # If a card or token would be put into your graveyard from anywhere, exile it instead.
      class ExileInsteadOfYourGraveyard < ReplacementEffect
        def applies?(effect)
          effect.to.graveyard? && effect.to.owner == receiver.controller
        end

        def call(effect)
          if effect.target.is_a?(Permanent)
            Effects::ExilePermanent.new(source: receiver, target: effect.target)
          else
            Effects::ExileCard.new(source: receiver, target: effect.target)
          end
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)

      def replacement_effects
        { Effects::MoveCardZone => ExileInsteadOfYourGraveyard, Effects::MovePermanentZone => ExileInsteadOfYourGraveyard }
      end
    end
  end
end
