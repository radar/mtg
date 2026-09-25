module Magic
  module Cards
    class DoublingSeason < Enchantment
      card_name "Doubling Season"
      cost generic: 4, green: 1

      def replacement_effects
        [
          [Effects::CreateToken, ReplacementEffect::TokenDoubler],
          *ReplacementEffect::CountersOnYourPermanentsDoubler.registrations,
        ]
      end
    end
  end
end
