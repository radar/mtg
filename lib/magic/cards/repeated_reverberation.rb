module Magic
  module Cards
    RepeatedReverberation = Instant("Repeated Reverberation") do
      cost "{2}{R}{R}"
    end

    class RepeatedReverberation < Instant
      attr_reader :active_turn

      def resolve!
        @active_turn = game.current_turn.number
        @used = false
      end

      def used?
        !!@used
      end

      def mark_used!
        @used = true
      end

      def pending?
        !used? && active_turn == game.current_turn.number
      end

      class SpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && actor.pending? && (spell.instant? || spell.sorcery?)
        end

        def call
          actor.mark_used!
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets, copies: 2)
        end
      end

      class LoyaltyTrigger < TriggeredAbility
        def should_perform?
          you? && actor.pending? && event.ability.is_a?(Magic::LoyaltyAbility)
        end

        def call
          actor.mark_used!
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: event.ability, targets: event.targets, copies: 2)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellTrigger, Events::AbilityActivated => LoyaltyTrigger }
      end
    end
  end
end
