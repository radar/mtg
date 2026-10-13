module Magic
  module Cards
    class Putrefy < Instant
      card_name "Putrefy"
      cost generic: 1, black: 1, green: 1

      def target_choices
        battlefield.permanents.by_any_type(T::Artifact, T::Creature)
      end

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end