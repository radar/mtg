module Magic
  module Cards
    Scrapshooter = Creature("Scrapshooter") do
      cost generic: 1, green: 2
      creature_type("Raccoon Archer")
      keywords :reach
      power 4
      toughness 4
      gift :card
    end

    class Scrapshooter < Creature
      # When this creature enters, if the gift was promised, destroy target artifact or enchantment an
      # opponent controls.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class DestroyChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).by_any_type("Artifact", "Enchantment")
          end

          def choice_amount = 1

          def resolve!(target:)
            destroy(target)
          end
        end

        def should_perform? = actor.gift_promised?

        def call
          choice = DestroyChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
