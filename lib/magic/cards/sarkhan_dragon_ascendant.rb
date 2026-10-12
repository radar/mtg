module Magic
  module Cards
    SarkhanDragonAscendant = Creature("Sarkhan, Dragon Ascendant") do
      cost generic: 1, red: 1
      legendary_creature_type("Human Druid")
      power 2
      toughness 2
    end

    class SarkhanDragonAscendant < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class BeholdChoice < Magic::Choice::Behold
          def resolve!(**args)
            super(**args)
            create_token(token: Tokens::Treasure)
          end
        end

        def call
          game.choices.add(BeholdChoice.new(actor: actor, type: "Dragon")) if Magic::Choice::Behold.new(actor: actor, type: "Dragon").candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      class TribalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent.type?("Dragon")
        end

        def call
          add_counter("+1/+1", to: actor)
          actor.add_types(T::Creatures["Dragon"])
          trigger_effect(:grant_keyword, target: actor, keyword: :flying)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => TribalEntersTrigger }
    end
  end
end
