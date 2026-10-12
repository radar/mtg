module Magic
  module Cards
    StormOfSouls = Sorcery("Storm of Souls") do
      cost generic: 4, white: 2
    end

    class StormOfSouls < Sorcery
      # "Return all creature cards from your graveyard to the battlefield. Each of them is a 1/1 Spirit with flying in
      # addition to its other types. Exile Storm of Souls."
      def exile_as_it_resolves? = true

      def resolve!
        controller.graveyard.cards.select { |card| card.type?("Creature") }.to_a.each do |card|
          permanent = card.resolve!
          next unless permanent.is_a?(Permanent)

          permanent.modify_base_power(1, until_eot: false)
          permanent.modify_base_toughness(1, until_eot: false)
          permanent.add_types(T::Creatures["Spirit"], until_eot: false)
          permanent.grant_keyword(Keywords::FLYING, until_eot: false)
          permanent.apply_continuous_effects!
        end
      end
    end
  end
end
