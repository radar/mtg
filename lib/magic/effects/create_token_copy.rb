module Magic
  module Effects
    # "Create a token that's a copy of {card}", optionally with its base power and toughness set (offspring: 1/1).
    # A CreateToken, so token doublers (Anointed Procession) and other token replacements apply to it.
    class CreateTokenCopy < CreateToken
      attr_reader :card

      def initialize(card:, base_power: nil, base_toughness: nil, **args)
        super(token_class: nil, base_power: base_power, base_toughness: base_toughness, **args)
        @card = card
      end

      def resolve!
        amount.times.map do
          token = Permanent.resolve(game: game, owner: controller, card: card, token: true, copy: true, cast: false)
          token.modify_base_power(base_power, until_eot: false) if base_power
          token.modify_base_toughness(base_toughness, until_eot: false) if base_toughness
          token
        end
      end
    end
  end
end
