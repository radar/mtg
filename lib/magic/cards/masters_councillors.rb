module Magic
  module Cards
    MastersCouncillors = Creature("Master's Councillors") do
      cost generic: 1, blue: 1
      creature_type "Human Advisor"
      power 1
      toughness 3
      keywords :vigilance
    end

    class MastersCouncillors < Creature
      # "This creature gets +2/+0 for each graveyard with seven or more cards in it."
      class GraveyardPower < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          2 * source.game.players.count { |player| player.graveyard.cards.count >= 7 }
        end

        def toughness_modification = 0
      end

      # "Whenever you draw your second card each turn, target player mills three cards."
      class SecondCardDrawTrigger < TriggeredAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.players

          def choice_amount = 1

          def resolve!(target:)
            target.mill(3)
          end
        end

        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      def static_abilities = [GraveyardPower]

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
