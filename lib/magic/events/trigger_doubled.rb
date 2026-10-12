module Magic
  module Events
    # A triggered ability triggers an additional time because of +source+ (Panharmonicon).
    class TriggerDoubled < Base
      attr_reader :permanent

      def initialize(source:, permanent:)
        @permanent = permanent
        super(source: source)
      end

      def inspect
        "#<Events::TriggerDoubled source: #{source&.name}, permanent: #{permanent.name}>"
      end
    end
  end
end
