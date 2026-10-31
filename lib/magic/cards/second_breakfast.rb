module Magic
  module Cards
    SecondBreakfast = Instant("Second Breakfast") do
      cost generic: 2, white: 1
    end

    class SecondBreakfast < Instant
      # One list per target slot; a third target has no slot and is rejected, fewer than two is allowed.
      def multi_target? = true

      def target_choices = [battlefield.creatures, battlefield.creatures]

      def distinct_targets? = true

      # "Up to two target creatures each get +2/+1 until end of turn. Create a Food token."
      def resolve!(targets: [])
        targets.each { |target| pump(target, 2, 1) }
        create_token(token: Tokens::Food)
      end
    end
  end
end
