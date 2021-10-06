module Magic
  module Effects
    class AddCounter < Effect
      attr_reader :power, :toughness

      def initialize(power: 1, toughness: 1, **args)
        @power = power
        @toughness = toughness
        super(**args)
      end

      def requires_choices?
        true
      end

      def resolve(targets:)
        raise InvalidTarget if targets.any? { |target| !choices.include?(target) }

        targets.each do |target|
          target.add_counter(power: power, toughness: toughness)
        end
      end
    end
  end
end
