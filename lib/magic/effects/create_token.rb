module Magic
  module Effects
    class CreateToken < Effect
      attr_reader :controller, :token_class, :amount, :base_power, :base_toughness, :enters_tapped

      def initialize(source:, controller: source.controller, token_class:, amount: 1, base_power: nil, base_toughness: nil, enters_tapped: false, **args)
        super(source: source, **args)
        @controller = controller
        @token_class = token_class
        @amount = amount
        @base_power = base_power || token_class::POWER
        @base_toughness = base_toughness || token_class::TOUGHNESS
        @enters_tapped = enters_tapped
      end

      def inspect
        "#<Effects::CreateToken source:#{source} token_class:#{token_class} amount:#{amount} controller:#{controller}>"
      end

      def resolve!
        amount.times.map do
          token_class.new(
            game: game,
            owner: controller,
            base_power: base_power,
            base_toughness: base_toughness,
          ).resolve!(enters_tapped: enters_tapped)
        end
      end
    end
  end
end
