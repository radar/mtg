module Magic
  module Effects
    class AddCounter < Effect
      attr_reader :counter_type

      def initialize(counter_type, **args)
        @counter_type = counter_type
        super(**args)
      end

      def requires_choices?
        true
      end

      def multiple_targets?
        true
      end

      def resolve(targets:)
        raise InvalidTarget if targets.any? { |target| !choices.include?(target) }

        targets.each do |target|
          target.add_counter(counter_type)
        end
      end
    end
  end
end
