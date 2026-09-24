module Magic
  module Cards
    AcademyManufactor = Creature("Academy Manufactor") do
      cost generic: 3
      artifact_creature_type "Assembly-Worker"
      power 1
      toughness 3
    end

    class AcademyManufactor < Creature
      TOKEN_CLASSES = [Tokens::Clue, Tokens::Food, Tokens::Treasure].freeze

      # If you would create a Clue, Food, or Treasure token, instead create one of each.
      class OneOfEach < ReplacementEffect
        def applies?(effect)
          effect.controller == receiver.controller && TOKEN_CLASSES.include?(effect.token_class)
        end

        def call(effect)
          Effects::Multiple.new(
            source: effect.source,
            effects: TOKEN_CLASSES.map do |token_class|
              Effects::CreateToken.new(
                source: effect.source,
                controller: effect.controller,
                token_class: token_class,
                amount: effect.amount,
                enters_tapped: effect.enters_tapped,
              )
            end,
          )
        end
      end

      def replacement_effects
        { Effects::CreateToken => OneOfEach }
      end
    end
  end
end
