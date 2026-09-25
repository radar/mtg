module Magic
  module Cards
    AnointedProcession = Enchantment("Anointed Procession") do
      cost generic: 3, white: 1
    end

    class AnointedProcession < Enchantment
      def replacement_effects = { Effects::CreateToken => ReplacementEffect::TokenDoubler }
    end
  end
end
