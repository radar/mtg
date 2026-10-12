module Magic
  module Cards
    class WarSqueak < Aura
      card_name "War Squeak"
      cost red: 1

      enchant "Creature"

      def target_choices = battlefield.creatures

      # Enchanted creature gets +1/+1 and has haste.
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class Haste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applies_to_target
      end

      def static_abilities = [Buff, Haste]

      # When this Aura enters, target creature an opponent controls can't block this turn.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CantBlockChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            target.prevent_blocking!
          end
        end

        def call
          choice = CantBlockChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
