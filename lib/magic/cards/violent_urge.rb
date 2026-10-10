module Magic
  module Cards
    ViolentUrge = Instant("Violent Urge") do
      cost red: 1
    end

    class ViolentUrge < Instant
      def single_target? = true

      def target_choices = battlefield.creatures

      # "Target creature gets +1/+0 and gains first strike until end of turn. Delirium — If there are four or more
      # card types among cards in your graveyard, that creature gains double strike until end of turn."
      def resolve!(target:)
        target.modify_power(1)
        target.grant_first_strike!
        target.grant_keyword(Keywords::DOUBLE_STRIKE) if controller.graveyard.delirium?
      end
    end
  end
end
