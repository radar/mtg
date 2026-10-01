module Magic
  module Effects
    class CreateToken < Effect
      # attack_target: who an attacking token attacks (Mobilize: what the mobilizing creature attacks);
      # nil leaves the target to be chosen, as for Falconer Adept.
      attr_reader :controller, :token_class, :amount, :base_power, :base_toughness, :enters_tapped, :attacking, :attack_target

      def initialize(source:, controller: source.controller, token_class:, amount: 1, base_power: nil, base_toughness: nil, enters_tapped: false, attacking: false, attack_target: nil, **args)
        super(source: source, **args)
        @controller = controller
        @token_class = token_class
        @amount = amount
        @base_power = base_power || (token_class.const_defined?(:POWER) ? token_class::POWER : nil)
        @base_toughness = base_toughness || (token_class.const_defined?(:TOUGHNESS) ? token_class::TOUGHNESS : nil)
        @enters_tapped = enters_tapped
        @attacking = attacking
        @attack_target = attack_target
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
          game.current_turn.declare_attacker(token, target: attack_target) if attacking
          token
        end
      end
    end
  end
end
