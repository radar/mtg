module Magic
  module Cards
    class Arachnogenesis < Instant
      card_name "Arachnogenesis"
      cost generic: 2, green: 1

      SpiderToken = Token.create("Spider") do
        creature_type "Spider"
        power 1
        toughness 2
        colors :green
        keywords :reach
      end

      def resolve!
        attacking_creatures = game.battlefield.creatures.attacking.count
        trigger_effect(:create_token, token_class: SpiderToken, amount: attacking_creatures)
        super
      end
    end
  end
end