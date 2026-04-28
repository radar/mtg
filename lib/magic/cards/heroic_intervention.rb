module Magic
  module Cards
    HeroicIntervention = Instant("Heroic Intervention") do
      cost generic: 1, green: 1
    end

    class HeroicIntervention < Instant
      def resolve!
        owner.permanents.each do
          _1.grant_hexproof!
          _1.grant_indestructible!
        end
      end
    end
  end
end
