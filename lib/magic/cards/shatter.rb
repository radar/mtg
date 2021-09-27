module Magic
  module Cards
    class Shatter < Instant
      def initialize(**args)
        super(
          name: "Shatter",
          **args
        )
      end

      def resolve!
        game.add_effect(
          Effects::Destroy.new(
            valid_targets: -> (c) { c.artifact? }
          )
        )
        super
      end
    end
  end
end
