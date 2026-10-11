module Magic
  module Cards
    class TheRollercrusherRide < Enchantment
      card_name "The Rollercrusher Ride"
      type T::Super::Legendary, T::Enchantment
      cost x: 1, generic: 2, red: 1

      # "Delirium -- If a source you control would deal noncombat damage to a permanent or player while there are four or
      # more card types among cards in your graveyard, it deals double that damage instead."
      class DeliriumDamageDoubler < ReplacementEffect::DamageDoubler
        def self.registrations = [[Effects::DealDamage, self]]

        def applies?(effect)
          super && receiver.controller.graveyard.delirium?
        end
      end

      def replacement_effects = DeliriumDamageDoubler.registrations

      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, amount:)
          super(actor: actor)
          @amount = amount
        end

        def prompt = "Choose up to #{@amount} target creatures. #{actor.name} deals #{@amount} damage to each."

        def choices = battlefield.creatures

        def choice_amount = 0..@amount

        def resolve!(targets:)
          raise ArgumentError, "at most #{@amount} creatures may be chosen" if targets.size > @amount

          targets.each { |target| trigger_effect(:deal_damage, damage: @amount, target: target) }
        end
      end

      # "When The Rollercrusher Ride enters, it deals X damage to each of up to X target creatures."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          x = actor.x_value.to_i
          return unless x.positive?

          choice = DamageChoice.new(actor: actor, amount: x)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
