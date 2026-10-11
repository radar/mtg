module Magic
  module Cards
    class ConductiveMachete < Equipment
      card_name "Conductive Machete"
      cost generic: 4
      equip [Costs::Mana.new(generic: 4)]

      # "When this Equipment enters, manifest dread, then attach this Equipment to that creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDreadAndAttach.perform(actor: actor)
        end
      end

      # "Equipped creature gets +2/+1."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 1
        applies_to_target
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [Buff]
    end
  end
end
