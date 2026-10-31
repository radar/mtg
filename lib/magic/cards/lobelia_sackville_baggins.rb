module Magic
  module Cards
    LobeliaSackvilleBaggins = Creature("Lobelia Sackville-Baggins") do
      cost generic: 2, black: 1
      legendary_creature_type "Halfling Citizen"
      power 2
      toughness 3
      keywords :flash, :menace
    end

    class LobeliaSackvilleBaggins < Creature
      # "...target creature card from an opponent's graveyard that was put there from the battlefield this turn,
      # then create X Treasure tokens, where X is the exiled card's power."
      class ExileChoice < Magic::Choice::Targeted
        def choices
          died = game.current_turn.events.select { _1.is_a?(Events::CreatureDied) }.map { _1.permanent.card }
          game.opponents(controller).flat_map { |opponent| opponent.graveyard.cards.to_a }
            .select { |card| card.creature? && died.any? { _1.equal?(card) } }
        end

        def choice_amount = 1

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          power = target.base_power.to_i
          exile_target(target)
          create_token(token: Tokens::Treasure, amount: power, controller:) if power.positive?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = event.permanent == actor

        def call
          choice = ExileChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
