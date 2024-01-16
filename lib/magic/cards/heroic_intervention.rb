module Magic
  module Cards
    HeroicIntervention = Instant("Heroic Intervention") do
      cost generic: 1, green: 1
    end

    class HeroicIntervention < Instant
      def resolve!
        owner.permanents.each do
          _1.grant_keyword(Keywords::HEXPROOF, until_eot: true)
          _1.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end
    end
  end
end
