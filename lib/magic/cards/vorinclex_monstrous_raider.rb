module Magic
  module Cards
    VorinclexMonstrousRaider = Creature("Vorinclex, Monstrous Raider") do
      cost generic: 4, green: 2
      legendary_creature_type("Phyrexian Praetor")
      keywords :trample, :haste
      power 6
      toughness 6
    end

    class VorinclexMonstrousRaider < Creature
      def replacement_effects = [ReplacementEffect::CountersYouPutDoubler, ReplacementEffect::CountersOpponentPutHalver].flat_map(&:registrations)
    end
  end
end
