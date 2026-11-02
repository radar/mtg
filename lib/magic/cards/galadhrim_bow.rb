module Magic
  module Cards
    GaladhrimBow = Equipment("Galadhrim Bow") do
      cost generic: 2, green: 1
      keywords :flash
      equip [Costs::Mana.new(generic: 2)], sorcery_speed: true
    end

    class GaladhrimBow < Equipment
      # "Equipped creature gets +1/+2 and has reach."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 2
        applies_to_target
      end

      class GrantReach < Abilities::Static::KeywordGrant
        keyword_grants Keywords::REACH
        applies_to_target
      end

      def static_abilities = [Buff, GrantReach]

      # "When this Equipment enters, attach it to target creature you control. Untap that creature."
      class AttachChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        def resolve!(target:)
          actor.attach_to!(target)
          target.untap!
        end

        # The target is mandatory (CR 603.3d): declining uses a legal creature.
        def decline!
          resolve!(target: choices.first) if choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = AttachChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
