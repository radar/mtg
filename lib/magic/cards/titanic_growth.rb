module Magic
  module Cards
    class TitanicGrowth < Instant
      card_name "Titanic Growth"
      cost generic: 1, green: 1

      def target_choices
        creatures
      end

      def resolve!(target:)
        pump(target, 4, 4)
      end
    end
  end
end
