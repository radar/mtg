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

      # "Create X 1/2 green Spider creature tokens with reach, where X is the number of creatures attacking you. Prevent
      # all combat damage that would be dealt this turn by non-Spider creatures."
      def resolve!
        attacking_you = game.current_turn.attacks.count { |attack| attack.defending_player == controller }
        trigger_effect(:create_token, token_class: SpiderToken, amount: attacking_you)
        game.current_turn.prevent_combat_damage_except_from("Spider")
        super
      end
    end
  end
end
