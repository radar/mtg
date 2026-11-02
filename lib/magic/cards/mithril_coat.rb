module Magic
  module Cards
    MithrilCoat = Equipment("Mithril Coat") do
      legendary_artifact
      cost generic: 3
      keywords :flash, :indestructible
      equip [Costs::Mana.new(generic: 3)], sorcery_speed: true
    end

    class MithrilCoat < Equipment
      # "Equipped creature has indestructible."
      class GrantIndestructible < Abilities::Static::KeywordGrant
        keyword_grants Keywords::INDESTRUCTIBLE
        applies_to_target
      end

      def static_abilities = [GrantIndestructible]

      # "When Mithril Coat enters, attach it to target legendary creature you control."
      class AttachChoice < Magic::Choice::Targeted
        def choices = controller.creatures.select(&:legendary?)

        def choice_amount = 1

        def resolve!(target:)
          actor.attach_to!(target)
        end

        # The target is mandatory (CR 603.3d): declining attaches to a legal creature.
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
