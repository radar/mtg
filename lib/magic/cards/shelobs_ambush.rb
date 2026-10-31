module Magic
  module Cards
    ShelobsAmbush = Instant("Shelob's Ambush") do
      cost black: 1
    end

    class ShelobsAmbush < Instant
      def target_choices = battlefield.creatures

      # "Target creature gets +1/+2 and gains deathtouch until end of turn. Create a Food token."
      def resolve!(target:)
        pump(target, 1, 2)
        give_keyword(target, :deathtouch)
        create_token(token: Tokens::Food)
      end
    end
  end
end
