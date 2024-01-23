module Magic
  module Effects
    class ApplyPowerToughnessModification < TargetedEffect
      attr_reader :power, :toughness

      def initialize(power: 0, toughness: 0, **args)
        @power = power
        @toughness = toughness
        super(**args)
      end

      def resolve(*targets)
        raise InvalidTarget if targets.any? { |target| !choices.include?(target) }

        targets.each do |target|
          target.modify_power(power) if power
          target.modify_toughness(toughness) if toughness
        end
      end
    end
  end
end
