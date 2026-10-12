module Magic
  module Cards
    FieryEmancipation = Enchantment("Fiery Emancipation") do
      cost "{3}{R}{R}{R}"
    end

    class FieryEmancipation < Enchantment
      # "If a source you control would deal damage to a permanent or player, it deals triple that damage to that
      # permanent or player instead."
      def replacement_effects = ReplacementEffect::DamageTripler.registrations
    end
  end
end
