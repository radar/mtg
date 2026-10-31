module Magic
  module Cards
    GaladrielGiftGiver = Creature("Galadriel, Gift-Giver") do
      cost generic: 3, green: 2
      legendary_creature_type "Elf Noble"
      power 4
      toughness 4
    end

    class GaladrielGiftGiver < Creature
      # "Whenever Galadriel enters or attacks, choose one --"
      # "Put a +1/+1 counter on another target creature." A real target, so hexproof, shroud and protection apply.
      class CounterChoice < Magic::Choice::Targeted
        def choices = game.battlefield.creatures.reject { _1 == actor }

        def choice_amount = 1

        def resolve!(target:)
          add_counter("+1/+1", to: target)
        end
      end

      class ModeChoice < Magic::Choice
        def modes
          {
            counter: "Put a +1/+1 counter on another target creature",
            food: "Create a Food token",
            treasure: "Create a Treasure token"
          }
        end

        def resolve!(mode:)
          case mode
          when :counter
            choice = CounterChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          when :food then create_token(token: Tokens::Food)
          when :treasure then create_token(token: Tokens::Treasure)
          else raise "Invalid mode chosen for Galadriel, Gift-Giver: #{mode}"
          end
        end

        # Choosing a mode is not optional, so skipping does nothing.
        def decline! = nil
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
