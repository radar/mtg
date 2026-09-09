module Magic
  module Cards
    class PestInfestation < Sorcery
      card_name "Pest Infestation"
      cost generic: 0, green: 1

      PestToken = Token.create("Pest") do
        creature_type "Pest"
        power 1
        toughness 1
        colors :black, :green
      end

      def resolve!
        amount = value_for_x || 0
        amount.times { trigger_effect(:create_token, token_class: PestToken, amount: 2) }
      end
    end
  end
end