module Magic
  module Effects
    class ApplyPowerToughnessModification < TargetedEffect
      attr_reader :power, :toughness

      def initialize(power: 0, toughness: 0, until_eot: true, **args)
        @power = power
        @toughness = toughness
        @until_eot = until_eot
        super(**args)
      end

      def inspect
        "#<#{self.class.name} power=#{power} toughness=#{toughness} target=#{target.name}>"
      end

      def resolve!
        target.modify_power(power, until_eot: @until_eot) if power
        target.modify_toughness(toughness, until_eot: @until_eot) if toughness
        game.notify!(Events::PowerToughnessModified.new(source: source, target: target, power: power, toughness: toughness, until_eot: @until_eot))
      end
    end
  end
end
