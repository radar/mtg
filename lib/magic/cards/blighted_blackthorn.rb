module Magic
  module Cards
    BlightedBlackthorn = Creature("Blighted Blackthorn") do
      cost generic: 4, black: 1
      creature_type("Treefolk Warlock")
      power 3
      toughness 7
    end

    class BlightedBlackthorn < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            def resolve!(**args)
              super(**args)
              trigger_effect(:draw_cards, number_to_draw: 1)
              trigger_effect(:lose_life, target: controller, life: 1)
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            def resolve!(**args)
              super(**args)
              trigger_effect(:draw_cards, number_to_draw: 1)
              trigger_effect(:lose_life, target: controller, life: 1)
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
