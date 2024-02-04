module Magic
  module Cards
    Shatter = Instant("Shatter") do
      cost generic: 1, red: 1
    end

    class Shatter < Instant
      def target_choices
        battlefield.permanents.by_any_type("Artifact")
      end

      def single_target?
        true
      end

      def resolve!(target:)
        target.destroy!
      end
    end
  end
end
