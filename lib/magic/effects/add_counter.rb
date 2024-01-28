module Magic
  module Effects
    class AddCounter < TargetedEffect
      attr_reader :counter_type

      def initialize(counter_type:, **args)
        @counter_type = counter_type
        super(**args)
      end

      def resolve!
        target.add_counter(counter_type)
      end
    end
  end
end
