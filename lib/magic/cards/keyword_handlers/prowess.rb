module Magic
  module Cards
    module KeywordHandlers
      class Prowess
        def self.perform(game:, spell:, permanent:)
          return if spell.creature?

          game.add_effect(Effects::ApplyBuff.new(
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
