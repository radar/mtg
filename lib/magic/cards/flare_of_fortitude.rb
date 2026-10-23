module Magic
  module Cards
    FlareOfFortitude = Instant("Flare of Fortitude") do
      cost generic: 2, white: 2
    end

    class FlareOfFortitude < Instant
      # "You may sacrifice a nontoken white creature rather than pay this spell's mana cost."
      def alternative_cost = Costs::SacrificeCreatureAlternativeCost.new(color: :white)

      # "Until end of turn, your life total can't change, and permanents you control gain hexproof and indestructible."
      def resolve!
        controller.freeze_life_total_until_eot!
        controller.permanents.each do |permanent|
          give_keyword(permanent, :hexproof)
          give_keyword(permanent, :indestructible)
        end
      end
    end
  end
end
