module Magic
  module Cards
    TheMindskinner = Creature("The Mindskinner") do
      cost blue: 3
      type T::Super::Legendary, T::Enchantment, T::Creature, T::Creatures["Nightmare"]
      power 10
      toughness 1
    end

    class TheMindskinner < Creature
      # "The Mindskinner can't be blocked."
      def can_be_blocked?(_) = false

      # "If a source you control would deal damage to an opponent, prevent that damage and each opponent mills that many cards."
      class MillInstead
        attr_reader :player, :amount

        def initialize(player:, amount:)
          @player = player
          @amount = amount
        end

        def resolve!
          player.mill(amount)
        end
      end

      class PreventDamageAndMill < ReplacementEffect::DamageDoubler
        def call(effect)
          MillInstead.new(player: effect.target, amount: effect.damage)
        end

        private

        # Only damage to a player (an opponent of the controller); creatures and planeswalkers are hurt as usual.
        def recipient_applies?(target) = target.is_a?(Magic::Player) && target != receiver.controller
      end

      def replacement_effects = ReplacementEffect::DamageDoubler.registrations.to_h { |matcher, _| [matcher, PreventDamageAndMill] }
    end
  end
end
