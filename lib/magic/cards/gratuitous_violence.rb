module Magic
  module Cards
    GratuitousViolence = Enchantment("Gratuitous Violence") do
      cost generic: 2, red: 3
    end

    class GratuitousViolence < Enchantment
      def replacement_effects = ReplacementEffect::CreatureDamageDoubler.registrations
    end
  end
end
