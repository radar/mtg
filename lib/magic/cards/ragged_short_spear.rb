module Magic
  module Cards
    RaggedShortSpear = Equipment("Ragged Short Spear") do
      cost generic: 1, red: 1
      equip [Costs::Mana.new(generic: 3)]
    end

    class RaggedShortSpear < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          class DiscardChoice < Magic::Choice::Discard
            def resolve!(**args)
              super(**args)
              trigger_effect(:draw_cards, number_to_draw: 2)
            end
          end

          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
