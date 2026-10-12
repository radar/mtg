module Magic
  module Cards
    GalionElvenkingsButler = Creature("Galion, Elvenking's Butler") do
      cost generic: 2, green: 2
      legendary_creature_type("Elf Advisor")
      power 4
      toughness 4
    end

    class GalionElvenkingsButler < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.except(actor)

          def choice_amount = 0..1

          def resolve!(target: nil)
            return unless target

            target.modify_base_power(actor.power)
            target.modify_base_toughness(actor.toughness)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
