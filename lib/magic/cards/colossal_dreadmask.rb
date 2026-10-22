module Magic
  module Cards
    ColossalDreadmask = Equipment("Colossal Dreadmask") do
      cost generic: 4, green: 2
      equip [Costs::Mana.new(generic: 3, green: 2)]
    end

    class ColossalDreadmask < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 6, toughness: 6
        applies_to_target
      end

      class EquippedCreatureTrample < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureTrample]

      # Living weapon: "When this Equipment enters, create a 0/0 black Phyrexian Germ creature token, then
      # attach this Equipment to it."
      class LivingWeaponTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          token = Array(create_token(token: MandibularKite::PhyrexianGermToken, controller: controller)).flatten.first
          actor.attach_to!(token) if token
        end
      end

      def etb_triggers = [LivingWeaponTrigger]
    end
  end
end
