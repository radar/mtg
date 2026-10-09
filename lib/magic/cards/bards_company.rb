module Magic
  module Cards
    BardsCompany = Creature("Bard's Company") do
      cost generic: 2, white: 1, blue: 1
      creature_type("Human Citizen")
      power 2
      toughness 3
    end

    class BardsCompany < Creature
      # "You may cast this spell as though it had flash if you control a Human."
      def flash?
        super || game.battlefield.controlled_by(controller || owner).any? { |permanent| permanent.type?("Human") }
      end

      # "Other creatures you control get +1/+1."
      class Anthem < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets
          source.controller.creatures - [source]
        end
      end

      def static_abilities = [Anthem]

      # "Whenever this creature enters or attacks, recruit."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          Recruit.call(player: controller)
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          Recruit.call(player: controller)
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge({ Events::CreatureAttacked => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
