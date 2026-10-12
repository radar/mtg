module Magic
  module Cards
    Mockingbird = Creature("Mockingbird") do
      cost x: 1, blue: 1
      creature_type("Bird Bard")
      keywords :flying
      power 1
      toughness 1
    end

    class Mockingbird < Creature
      enters_as_copy

      # You may have this creature enter as a copy of any creature on the battlefield with mana value less than or
      # equal to the amount of mana spent to cast this creature, except it's a Bird in addition to its other types
      # and it has flying.
      class CopyChoice < Magic::Choice::Targeted
        def choices
          spent = actor.mana_spent.values.sum
          game.battlefield.creatures.except(actor).select { _1.mana_value <= spent }
        end

        def choice_amount = 1

        def resolve!(target:)
          actor.copied_card = target.card
          actor.copy_choice_pending = false
          actor.add_types("Bird", until_eot: false)
          actor.grant_keyword(Keywords::FLYING, until_eot: false)
        end
      end

      class MayCopyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(CopyChoice.new(actor: actor))
        end

        def decline!
          actor.copy_choice_pending = false
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          if CopyChoice.new(actor: actor).choices.any?
            game.choices.add(MayCopyChoice.new(actor: actor))
          else
            actor.copy_choice_pending = false
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
