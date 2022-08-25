module Magic
  module Cards
    class Shatter < Instant
      NAME = "Shatter"
      COST = { generic: 1, red: 1 }

      def target_choices
        battlefield.permanents.by_any_type("Artifact")
      end

      def single_target?
        true
      end

      def resolve!(_controller, target:)
        target.destroy!
        super
      end
    end
  end
end
