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

      def resolve!
        target.modify_power(power) if power
        target.modify_toughness(toughness) if toughness
      end
    end
  end
end
