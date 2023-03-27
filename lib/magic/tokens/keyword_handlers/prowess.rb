module Magic
  module Tokens
    module KeywordHandlers
      class Prowess
        def self.perform(game:, spell:, permanent:)
          return if spell.controller != permanent.controller
          return if spell.creature?

          game.add_effect(Effects::ApplyPowerToughnessModification.new(
            choices: permanent,
            source: permanent,
            power: 1,
            toughness: 1,
          ))
        end
      end
    end
  end
end
