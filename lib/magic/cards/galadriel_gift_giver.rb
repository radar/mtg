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
      class ModeChoice < Magic::Choice
        def others = game.battlefield.creatures.reject { _1 == actor }

        def modes
          {
            counter: "Put a +1/+1 counter on another target creature",
            food: "Create a Food token",
            treasure: "Create a Treasure token"
          }
        end

        # target: the creature for the counter mode (defaults to the first other creature).
        def resolve!(mode:, target: nil)
          case mode
          when :counter
            target ||= others.first
            raise ArgumentError, "#{target&.name.inspect} is not another creature" unless others.include?(target)

            add_counter("+1/+1", to: target)
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
