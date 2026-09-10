module Magic
  module Cards
    ReclamationSage = Creature("Reclamation Sage") do
      cost generic: 2, green: 1
      creature_type "Elf Shaman"
      power 2
      toughness 1
    end

    class ReclamationSage < Creature
      class DestroyChoice < Magic::Choice::Targeted
        def choices
          game.battlefield.by_any_type("Artifact", "Enchantment")
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class MayDestroyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(ReclamationSage::DestroyChoice.new(actor: actor))
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ReclamationSage::MayDestroyChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
