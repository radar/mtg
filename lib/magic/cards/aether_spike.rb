module Magic
  module Cards
    class AetherSpike < Instant
      card_name "Aether Spike"
      cost generic: 1, blue: 1

      # Counter that spell unless its controller pays {1} for each {E} paid.
      class PayChoice < Magic::Choice::PayAnyEnergy
        attr_reader :spell

        def initialize(actor:, spell:)
          @spell = spell
          super(actor: actor)
        end

        def paid(amount)
          return if amount.zero?

          choice = Magic::Choice::CounterUnlessPay.new(actor: actor, spell: spell, mana: { generic: amount })
          if choice.can_pay?
            game.choices.add(choice)
          else
            counter_spell(spell)
          end
        end
      end

      def target_choices = game.stack.spells.reject { _1.card == self }

      # Choose target spell. You get {E}{E}, then you may pay any amount of {E}. Counter that spell unless its controller
      # pays {1} for each {E} paid this way.
      def resolve!(target:)
        gain_energy 2
        game.add_choice(PayChoice.new(actor: self, spell: target))
      end
    end
  end
end
