module Magic
  module Cards
    GiftOfTheViper = Instant("Gift of the Viper") do
      cost green: 1
    end

    class GiftOfTheViper < Instant
      def target_choices = battlefield.creatures

      # "Put a +1/+1 counter, a reach counter, and a deathtouch counter on target creature. Untap it."
      def resolve!(target:)
        add_counter("+1/+1", to: target)
        add_counter("reach", to: target)
        add_counter("deathtouch", to: target)
        target.untap!
      end
    end
  end
end
