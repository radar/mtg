module Magic
  module Cards
    CelestialArmor = Equipment("Celestial Armor") do
      cost generic: 2, white: 1
      keywords :flash
      equip [Costs::Mana.new(generic: 3, white: 1)]
    end

    class CelestialArmor < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureKeywords]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
            trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
            trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
