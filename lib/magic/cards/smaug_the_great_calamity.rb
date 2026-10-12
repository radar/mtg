module Magic
  module Cards
    SmaugTheGreatCalamity = Creature("Smaug, the Great Calamity") do
      legendary_creature_type "Dragon"
      cost generic: 5, red: 2
      keywords :flying
      power 5
      toughness 5
    end

    class SmaugTheGreatCalamity < Creature
      # Spew Flame {4}{R}, Sorcery -- Adventure: "Spew Flame deals 5 damage to target creature."
      adventure generic: 4, red: 1

      def target_choices = battlefield.creatures

      def adventure_resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 5)
      end
    end
  end
end
