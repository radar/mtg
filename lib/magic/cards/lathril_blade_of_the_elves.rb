module Magic
  module Cards
    LathrilBladeOfTheElves = Creature("Lathril, Blade of the Elves") do
      creature_type "Elf Noble"
      cost generic: 2, black: 1, green: 1
      power 2
      toughness 3
      keywords :menace
    end

    class LathrilBladeOfTheElves < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Tap.new(source), Costs::MultiTap.new(-> (c) { c.type?("Elf") }, 10)]

        def resolve!
          effect = Effects::LoseLife.new(
            source: source,
            targets: game.opponents(source.controller),
            life: 10
          )
          game.add_effect(effect)

          effect = Effects::GainLife.new(
            source: source,
            target: source.controller,
            life: 10
          )
          game.add_effect(effect)
        end
      end

      def activated_abilities = [ActivatedAbility]

      def event_handlers
        {
          Events::CombatDamageDealt => -> (receiver, event) do
            return unless event.target.player?

            event.damage.times do
              token = Tokens::ElfWarrior.new(game: game)
              token.resolve!(receiver.controller)
            end
          end
        }
      end
    end
  end
end