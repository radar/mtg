module Magic
  module Cards
    HighPerfectMorcant = Creature("High Perfect Morcant") do
      cost generic: 2, black: 1, green: 1
      legendary_creature_type "Elf Noble"
      power 4
      toughness 4
    end

    class HighPerfectMorcant < Creature
      # Whenever High Perfect Morcant or another Elf you control enters, each opponent blights 1.
      class ElfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && (event.permanent == actor || event.permanent.type?("Elf"))
        end

        def call
          game.opponents(controller).each do |opponent|
            choice = Magic::Choice::Blight.new(actor: actor, amount: 1, player: opponent)
            game.choices.add(choice) if choice.choices.any?
          end
        end
      end

      # Tap three untapped Elves you control: Proliferate. Activate only as a sorcery.
      class ProliferateAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(source, 3, type: "Elf")]

        def requirements_met?
          game.can_cast_sorcery?(controller)
        end

        def resolve!
          game.choices.add(Magic::Choice::Proliferate.new(actor: source))
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => ElfEntersTrigger }

      def activated_abilities = [ProliferateAbility]
    end
  end
end
