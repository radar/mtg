module Magic
  module Cards
    # The land back face of Suppression Ray. It has no mana cost.
    OrderlyPlaza = Card("Orderly Plaza") do
      type "Land"
    end

    class OrderlyPlaza < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      def activated_abilities = [ManaAbility]
    end

    SuppressionRay = Sorcery("Suppression Ray") do
      cost generic: 3, blue_or_white: 2
      back_face OrderlyPlaza
    end

    class SuppressionRay < Sorcery
      # "...choose up to that many creatures tapped this way. Put a stun counter on each of them." Answer with
      # `game.resolve_choice!(creatures: [...])`; declining chooses none.
      class StunChoice < Magic::Choice::May
        def initialize(actor:, creatures:, amount:)
          @creatures = creatures
          @amount = amount
          super(actor: actor)
        end

        def choices = @creatures

        def prompt = "Choose up to #{@amount} creatures to put a stun counter on."

        def resolve!(creatures: [])
          chosen = Array(creatures)
          raise ArgumentError, "choose at most #{@amount} creatures" if chosen.size > @amount || chosen.uniq.size != chosen.size
          raise ArgumentError, "choose only creatures tapped this way" unless (chosen - choices).empty?

          chosen.each { add_counter("stun", to: _1) }
        end
      end

      # "You may pay any amount of {E}. If you do, choose up to that many creatures tapped this way."
      class PayChoice < Magic::Choice::PayAnyEnergy
        def initialize(actor:, creatures:)
          @creatures = creatures
          super(actor: actor)
        end

        def paid(amount)
          return unless amount.positive? && @creatures.any?

          game.add_choice(StunChoice.new(actor: actor, creatures: @creatures, amount:))
        end
      end

      def target_choices = game.players

      # Tap all creatures target player controls.
      def resolve!(target:)
        tapped = target.creatures.reject(&:tapped?)
        tapped.each { tap_permanent(_1) }
        game.add_choice(PayChoice.new(actor: self, creatures: tapped)) if controller.energy.positive?
      end
    end
  end
end
