module Magic
  module Cards
    TheBlackArrow = Equipment("The Black Arrow") do
      legendary_artifact
      cost generic: 3
      keywords :flash
      equip [Costs::Mana.new(generic: 1)]
    end

    class TheBlackArrow < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class EquippedCreatureReach < Abilities::Static::KeywordGrant
        keyword_grants Keywords::REACH
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureReach]

      # "When The Black Arrow enters, it deals 1 damage to any target. If a Dragon is dealt damage this way, destroy it."
      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 1)
          return unless target.is_a?(Magic::Permanent) && target.type?("Dragon")

          trigger_effect(:destroy_target, target: target)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
