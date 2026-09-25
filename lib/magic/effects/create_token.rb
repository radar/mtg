module Magic
  module Effects
    class CreateToken < Effect
      attr_reader :controller, :token_class, :amount, :base_power, :base_toughness, :enters_tapped, :attacking

      def initialize(source:, controller: source.controller, token_class:, amount: 1, base_power: nil, base_toughness: nil, enters_tapped: false, attacking: false, **args)
        super(source: source, **args)
        @controller = controller
        @token_class = token_class
        @amount = amount
        @base_power = base_power || (token_class.const_defined?(:POWER) ? token_class::POWER : nil)
        @base_toughness = base_toughness || (token_class.const_defined?(:TOUGHNESS) ? token_class::TOUGHNESS : nil)
        @enters_tapped = enters_tapped
        @attacking = attacking
      end

      # A copy of this effect that creates a different number of tokens. Used by
      # replacement effects (Doubling Season etc.): everything else the original
      # effect specified (tapped, attacking, base P/T) carries over to the extra tokens.
      def with_amount(amount)
        dup.tap { |effect| effect.instance_variable_set(:@amount, amount) }
      end

      def inspect
        "#<Effects::CreateToken source:#{source} token_class:#{token_class} amount:#{amount} controller:#{controller}>"
      end

      def resolve!
        amount.times.map do
          token = token_class.new(
            game: game,
            owner: controller,
            base_power: base_power,
            base_toughness: base_toughness,
          ).resolve!(enters_tapped: enters_tapped)
          game.current_turn.declare_attacker(token) if attacking
          token
        end
      end
    end
  end
end
