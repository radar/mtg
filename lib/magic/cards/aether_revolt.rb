module Magic
  module Cards
    class AetherRevolt < Enchantment
      card_name "Aether Revolt"
      cost generic: 2, red: 2

      # Revolt — As long as a permanent left the battlefield under your control this turn, if a source you control
      # would deal noncombat damage to an opponent or a permanent an opponent controls, it deals that much damage
      # plus 2 instead.
      class DamageBoost < ReplacementEffect::DamageIncreaser
        def self.registrations = [[Effects::DealDamage, self]]

        def increase = 2

        def applies?(effect) = revolt? && super

        private

        # A permanent left the battlefield under your control this turn.
        def revolt?
          receiver.game.current_turn.events.any? do |event|
            event.is_a?(Events::LeftTheBattlefield) && event.permanent.controller == receiver.controller
          end
        end

        def recipient_applies?(target) = damaged_player(target) != receiver.controller
      end

      def replacement_effects = DamageBoost.registrations

      # Whenever you get one or more {E}, this enchantment deals that much damage to any target.
      class EnergyTrigger < TriggeredAbility
        class TargetChoice < Magic::Choice::Targeted
          def initialize(amount:, **args)
            @amount = amount
            super(**args)
          end

          def choices = game.any_target

          def choice_amount = 1

          def resolve!(target:)
            deal_damage(@amount, to: target)
          end
        end

        def should_perform?
          event.player == controller && Counters[event.counter_type] == Counters::Energy
        end

        def call
          game.add_choice(TargetChoice.new(actor: actor, amount: event.amount))
        end
      end

      def event_handlers = { Events::CounterAddedToPlayer => EnergyTrigger }
    end
  end
end
