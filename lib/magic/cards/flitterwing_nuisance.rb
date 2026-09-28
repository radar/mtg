module Magic
  module Cards
    FlitterwingNuisance = Creature("Flitterwing Nuisance") do
      cost blue: 1
      creature_type("Faerie Rogue")
      keywords :flying
      power 2
      toughness 2
    end

    class FlitterwingNuisance < Creature
      enters_with_counters "-1/-1", 1

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{U}, Remove 1 -1/-1 counters from {this}"

        # "Whenever a creature you control deals combat damage to a player or
        # planeswalker this turn, draw a card." -- a delayed trigger lasting the turn,
        # via Permanent#register_turn_trigger (cleared at cleanup!).
        class DamageTrigger < TriggeredAbility
          def should_perform?
            event.source.controller == controller && event.source.creature? &&
              (event.target.is_a?(Magic::Player) || event.target.planeswalker?)
          end

          def call
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end

        def resolve!
          source.register_turn_trigger(Events::CombatDamageDealt, DamageTrigger)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
