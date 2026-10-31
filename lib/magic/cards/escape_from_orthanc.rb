module Magic
  module Cards
    EscapeFromOrthanc = Instant("Escape from Orthanc") do
      cost white: 1
    end

    class EscapeFromOrthanc < Instant
      def target_choices
        battlefield.creatures
      end

      # "Target creature gets +1/+3 and gains flying until end of turn. Untap it."
      def resolve!(target:)
        pump(target, 1, 3)
        give_keyword(target, :flying)
        target.untap!
      end
    end
  end
end
