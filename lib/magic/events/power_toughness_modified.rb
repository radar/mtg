module Magic
  module Events
    # +target+ gets +power+/+toughness+ (until end of turn unless +until_eot+ is false): a pump effect resolved.
    class PowerToughnessModified < Base
      attr_reader :target, :power, :toughness

      def initialize(source:, target:, power:, toughness:, until_eot: true)
        @target = target
        @power = power.to_i
        @toughness = toughness.to_i
        @until_eot = until_eot
        super(source: source)
      end

      def until_eot? = @until_eot

      def inspect
        "#<Events::PowerToughnessModified target: #{target.name}, power: #{power}, toughness: #{toughness}>"
      end
    end
  end
end
