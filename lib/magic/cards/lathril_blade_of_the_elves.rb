module Magic
  module Cards
    LathrilBladeOfTheElves = Creature("Lathril, Blade of the Elves") do
      type T::Super::Legendary, T::Creature, *creature_types("Elf Noble")
      cost generic: 2, black: 1, green: 1
      power 2
      toughness 3
      keywords :menace
    end

    class LathrilBladeOfTheElves < Creature
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::SelfTap.new(source), Costs::MultiTap.new(-> (c) { c.type?("Elf") }, 10)]

        def resolve!
          opponents = game.opponents(source.controller)
          opponents.each do |opponent|
            source.trigger_effect(:lose_life, source: source, life: 10, target: opponent)
          end

          source.trigger_effect(:gain_life, source: source, life: 10, target: source.controller)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class ElfSpawner < TriggeredAbility
        def should_perform?
          event.target.player?
        end

        def call
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken, amount: event.damage)
        end
      end

      def event_handlers
        {
          Events::CombatDamageDealt => ElfSpawner
        }
      end
    end
  end
end
