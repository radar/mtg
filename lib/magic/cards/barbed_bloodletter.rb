module Magic
  module Cards
    class BarbedBloodletter < Equipment
      card_name "Barbed Bloodletter"
      cost generic: 1, black: 1
      keywords :flash
      equip [Costs::Mana.new(generic: 2)]

      class AttachChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        # "... attach it to target creature you control. That creature gains wither until end of turn."
        def resolve!(target:)
          actor.attach_to!(target)
          trigger_effect(:grant_keyword, target:, keyword: :wither)
        end
      end

      # "When this Equipment enters, attach it to target creature you control. That creature gains
      # wither until end of turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = AttachChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Equipped creature gets +1/+2."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 2
        applies_to_target
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [Buff]
    end
  end
end
