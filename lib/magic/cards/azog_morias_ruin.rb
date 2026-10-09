module Magic
  module Cards
    AzogMoriasRuin = Creature("Azog, Moria's Ruin") do
      cost generic: 2, black: 1
      legendary_creature_type("Goblin Soldier")
      power 1
      toughness 3
    end

    class AzogMoriasRuin < Creature
      # "When Azog enters, destroy up to one other target creature. Its controller amasses Goblins X, where X
      # is that creature's power. If you controlled that creature, draw a card."
      class Choice < Magic::Choice::Targeted
        def prompt = "Destroy up to one other target creature."

        def choices
          game.battlefield.creatures.reject { _1 == actor }
        end

        def choice_amount = 0..1

        def resolve!(target:)
          victim_controller = target.controller
          power = [target.power, 0].max
          trigger_effect(:destroy_target, target: target)
          Amass.call(source: actor, controller: victim_controller, amount: power)
          trigger_effect(:draw_cards, number_to_draw: 1) if victim_controller == controller
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = Choice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
