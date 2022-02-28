module Magic
  module Cards
    class Shatter < Instant
      NAME = "Shatter"
      COST = { any: 1, red: 1 }

      def resolve!
        add_effect("DestroyTarget", choices: battlefield.cards.select(&:artifact?))
        super
      end
    end
  end
end
