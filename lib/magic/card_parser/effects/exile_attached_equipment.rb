# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile up to one target Equipment attached to that creature." (Fiery Annihilation, after "~ deals 5 damage to
      # target creature."). Not a real target of the spell: a `Choice::ExileAttachedEquipment` is queued as the spell
      # resolves, skipped with `game.skip_choice!` (none is also fine). Only after an effect that targeted a creature.
      class ExileAttachedEquipment < Data.define
        include Effect

        LINE = /\AExile up to one target Equipment attached to that creature\.?\z/i

        def self.parse(text)
          new if LINE.match?(text)
        end

        def earlier_target? = true

        def resolve_call
          <<~RUBY.chomp
            choice = Magic::Choice::ExileAttachedEquipment.new(actor: #{Effect::THIS}, creature: target)
            game.add_choice(choice) if choice.choices.any?
          RUBY
        end
      end
    end
  end
end
