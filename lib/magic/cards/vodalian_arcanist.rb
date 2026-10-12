module Magic
  module Cards
    VodalianArcanist = Creature("Vodalian Arcanist") do
      cost generic: 1, blue: 1
      creature_type "Merfolk Wizard"
      power 1
      toughness 3
    end

    class VodalianArcanist < Creature
      # "{T}: Add {C}. Spend this mana only to cast an instant or sorcery spell."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 1 }

        def mana_restriction = ManaRestriction::InstantOrSorcerySpell.new
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
