module Magic
  module Cards
    class StarforgedSword < Equipment
      card_name "Starforged Sword"
      cost generic: 4
      gift :tapped_fish
      equip [Costs::Mana.new(generic: 3)]

      # Equipped creature gets +3/+3 and loses flying.
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 3
        applies_to_target
      end

      class LosesFlying < Abilities::Static::KeywordRemoval
        keyword_removals Keywords::FLYING
        applies_to_target
      end

      def static_abilities = [Buff, LosesFlying]

      # When this Equipment enters, if the gift was promised, attach this Equipment to target creature you control.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class AttachChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
          end
        end

        def should_perform? = actor.gift_promised?

        def call
          choice = AttachChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
