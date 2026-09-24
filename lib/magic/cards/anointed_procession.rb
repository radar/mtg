module Magic
  module Cards
    AnointedProcession = Enchantment("Anointed Procession") do
      cost generic: 3, white: 1
    end

    class AnointedProcession < Enchantment
      class TokenDoubler < ReplacementEffect
        def applies?(effect)
          effect.controller == receiver.controller
        end

        def call(effect)
          Effects::CreateToken.new(
            source: receiver,
            token_class: effect.token_class,
            controller: receiver.controller,
            amount: effect.amount * 2,
          )
        end
      end

      def replacement_effects = { Effects::CreateToken => TokenDoubler }
    end
  end
end
