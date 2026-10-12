module Magic
  module Cards
    GollumTheAbandoned = Creature("Gollum the Abandoned") do
      cost generic: 1, black: 1
      legendary_creature_type "Halfling Horror"
      power 2
      toughness 2
    end

    class GollumTheAbandoned < Creature
      # "Gollum can't block."
      def can_block?(_) = false

      # "When Gollum enters, exile up to one target card from an opponent's graveyard. Each opponent loses 2 life."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.opponents(controller).flat_map { |opponent| opponent.graveyard.cards.to_a }
          end

          def choice_amount = 0..1

          def resolve!(target:)
            target.exile!
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
          game.opponents(controller).each { |opponent| trigger_effect(:lose_life, target: opponent, life: 2) }
        end
      end

      # "{2}, Sacrifice an artifact or creature: Return this card from your graveyard to your hand.
      # Activate only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2),
            Costs::Sacrifice.new(source, controller.permanents.select { |permanent| permanent.creature? || permanent.artifact? }),
          ]
        end

        activate_from_graveyard_as_sorcery

        def resolve!
          source.move_to_hand!(source.owner)
        end
      end

      def etb_triggers = [EntersTrigger]
      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
