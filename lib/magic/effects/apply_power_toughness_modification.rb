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
          target.modify_power_toughness!(power: power, toughness: toughness)
        end
      end
    end
  end
end
