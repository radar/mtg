module Magic
  module Cards
    class OmniChangeling < Creature
      card_name "Omni-Changeling"
      cost generic: 3, blue: 2
      creature_type "Shapeshifter"
      power 0
      toughness 0
      keywords :changeling
      convoke
      enters_as_copy

      class CopyChoice < Magic::Choice::Targeted
        def choices = game.battlefield.creatures.except(actor)

        def choice_amount = 1

        # "... as a copy of any creature on the battlefield, except it has changeling."
        def resolve!(target:)
          actor.copied_card = target.copiable_card
          actor.gain_all_creature_types!
          actor.copy_choice_pending = false
        end
      end

      class MayCopyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(CopyChoice.new(actor:))
        end

        def decline!
          actor.copy_choice_pending = false
        end
      end

      # "You may have this creature enter as a copy of any creature on the battlefield, except it has
      # changeling."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          if game.battlefield.creatures.except(actor).any?
            game.choices.add(MayCopyChoice.new(actor:))
          else
            actor.copy_choice_pending = false
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
