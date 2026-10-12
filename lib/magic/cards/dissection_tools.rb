module Magic
  module Cards
    class DissectionTools < Equipment
      card_name "Dissection Tools"
      cost generic: 5

      # "When this Equipment enters, manifest dread, then attach this Equipment to that creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDreadAndAttach.perform(actor: actor)
        end
      end

      # "Equipped creature gets +2/+2 and has deathtouch and lifelink."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class KeywordGrants < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH, Keywords::LIFELINK
        applies_to_target
      end

      # "Equip -- Sacrifice a creature."
      class EquipAbility < Magic::ActivatedAbility
        costs "Sacrifice a creature"

        def target_choices
          creatures_you_control
        end

        def equip? = true

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [Buff, KeywordGrants]
      def activated_abilities = [EquipAbility]
    end
  end
end
