module Magic
  module Cards
    CranialRam = Equipment("Cranial Ram") do
      cost black: 1, red: 1
      equip [Costs::Mana.new(generic: 2)]
    end

    class CranialRam < Equipment
      PhyrexianGermToken = Token.create("Phyrexian Germ") do
        creature_type "Phyrexian Germ"
        power 0
        toughness 0
        colors :black
      end

      # "Equipped creature gets +X/+1, where X is the number of artifacts you control."
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification = source.controller.permanents.count { _1.type?("Artifact") }

        def toughness_modification = 1
      end

      def static_abilities = [EquippedCreatureBuff]

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
