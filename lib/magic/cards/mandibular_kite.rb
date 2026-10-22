module Magic
  module Cards
    MandibularKite = Equipment("Mandibular Kite") do
      cost white: 1
      equip [Costs::Mana.new(generic: 3, white: 1)]
    end

    class MandibularKite < Equipment
      PhyrexianGermToken = Token.create("Phyrexian Germ") do
        creature_type "Phyrexian Germ"
        power 0
        toughness 0
        colors :black
      end

      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class EquippedCreatureFlying < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureFlying]

      # Living weapon: "When this Equipment enters, create a 0/0 black Phyrexian Germ creature token, then
      # attach this Equipment to it."
      class LivingWeaponTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          token = Array(create_token(token: PhyrexianGermToken, controller: controller)).flatten.first
          actor.attach_to!(token) if token
        end
      end

      def etb_triggers = [LivingWeaponTrigger]
    end
  end
end
