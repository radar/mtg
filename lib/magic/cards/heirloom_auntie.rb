module Magic
  module Cards
    HeirloomAuntie = Creature("Heirloom Auntie") do
      cost generic: 2, black: 1
      creature_type("Goblin Warlock")
      power 4
      toughness 4
    end

    class HeirloomAuntie < Creature
      enters_with_counters "-1/-1", 2

      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent != actor
        end

        class SurveilChoice < Magic::Choice::Surveil
          def resolve!(**args)
            super(**args)
            trigger_effect(:remove_counter, counter_type: Counters::Minus1Minus1, target: actor, amount: 1) if actor.counters.of_type(Counters::Minus1Minus1).count >= 1
          end
        end

        def call
          game.choices.add(SurveilChoice.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiesTrigger }
    end
  end
end
