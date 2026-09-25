# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "If that creature would die this turn, exile it instead." Follows an effect that
      # targeted a creature ("~ deals 5 damage to target creature."), so `target` is in scope.
      class ExileInsteadIfDies < Data.define
        include Effect

        LINE = /\AIf that creature would die this turn, exile it instead\.?\z/i

        def self.parse(text)
          new if LINE.match?(text)
        end

        def resolve_call = "target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)"
      end
    end
  end
end
