module Magic
  module Cards
    KastralTheWindcrested = Creature("Kastral, the Windcrested") do
      legendary_creature_type "Bird Scout"
      cost generic: 3, white: 1, blue: 1
      keywords :flying
      power 4
      toughness 5
    end

    class KastralTheWindcrested < Creature
      # Whenever one or more Birds you control deal combat damage to a player, choose one -- you may put a Bird
      # creature card from your hand or graveyard onto the battlefield with a finality counter on it; put a +1/+1
      # counter on each Bird you control; or draw a card.
      class BirdDamage < TriggeredAbility
        class BirdChoice < Magic::Choice::Targeted
          def choices
            [*controller.hand.cards, *controller.graveyard.cards].select { _1.creature? && _1.type?("Bird") }
          end

          def choice_amount = 1

          def resolve!(target:)
            permanent = Permanent.put_onto_battlefield(card: target, game: game, from_zone: target.zone, controller: controller)
            permanent&.add_counter("finality")
          end
        end

        class ModeChoice < Magic::Choice
          def choices = %i[put_bird counters draw]

          def resolve!(mode:)
            case mode
            when :put_bird
              choice = BirdChoice.new(actor: actor)
              game.choices.add(choice) if choice.choices.any?
            when :counters
              battlefield.controlled_by(controller).creatures.select { _1.type?("Bird") }.each do |bird|
                trigger_effect(:add_counter, counter_type: "+1/+1", target: bird, amount: 1)
              end
            when :draw
              draw_card
            else
              raise ArgumentError, "choose :put_bird, :counters or :draw"
            end
          end
        end

        def should_perform?
          source = event.source
          event.target.is_a?(Player) && source.is_a?(Permanent) && source.controller == controller && source.type?("Bird")
        end

        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(Events::CombatDamageDealt => BirdDamage)
    end
  end
end
