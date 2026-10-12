module Magic
  module Cards
    VeteranSurvivor = Creature("Veteran Survivor") do
      cost white: 1
      creature_type "Human Survivor"
      power 2
      toughness 1
    end

    class VeteranSurvivor < Creature
      # The cards this creature has exiled.
      def exiled_cards = (@exiled_cards ||= [])

      # "Survival — At the beginning of your second main phase, if this creature is tapped, exile up to one target card
      # from a graveyard."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.players.flat_map { _1.graveyard.cards.to_a }
          end

          def choice_amount = 0..1

          def resolve!(target:)
            target.exile!
            actor.exiled_cards << target
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "As long as there are three or more cards exiled with this creature, it gets +3/+3 ..."
      class ExiledBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 3

        conditions { source.exiled_cards.count { _1.zone&.exile? } >= 3 }
        applicable_targets { [source] }
      end

      # "... and has hexproof."
      class ExiledHexproof < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF

        conditions { source.exiled_cards.count { _1.zone&.exile? } >= 3 }
        applicable_targets { [source] }
      end

      def static_abilities = [ExiledBoost, ExiledHexproof]

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
