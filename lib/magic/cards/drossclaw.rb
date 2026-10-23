module Magic
  module Cards
    Drossclaw = Equipment("Drossclaw") do
      cost generic: 1, black: 1
      equip [Costs::Mana.new(generic: 2)]
    end

    class Drossclaw < Equipment
      PhyrexianGermToken = Token.create("Phyrexian Germ") do
        creature_type "Phyrexian Germ"
        power 0
        toughness 0
        colors :black
      end

      # "Equipped creature gets +1/+1."
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      # Living weapon: "When this Equipment enters, create a 0/0 black Phyrexian Germ creature token, then
      # attach this Equipment to it."
      class LivingWeaponTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          token = Array(create_token(token: PhyrexianGermToken, controller: controller)).flatten.first
          actor.attach_to!(token) if token
        end
      end

      # "Whenever equipped creature attacks, each opponent loses 1 life."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = actor.attached_to && event.attacks.any? { _1.attacker == actor.attached_to }

        def call
          opponents.each { lose_life(_1, 1) }
        end
      end

      def static_abilities = [EquippedCreatureBuff]

      def etb_triggers = [LivingWeaponTrigger]

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
