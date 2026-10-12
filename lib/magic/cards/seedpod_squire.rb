module Magic
  module Cards
    SeedpodSquire = Creature("Seedpod Squire") do
      cost "{3}{W/U}"
      creature_type("Bird Scout")
      keywords :flying
      power 3
      toughness 3
    end

    class SeedpodSquire < Creature
      # Whenever this creature attacks, target creature you control without flying gets +1/+1 until end of turn.
      class AttacksTrigger < TriggeredAbility
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.reject(&:flying?)

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 1)
          end
        end

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          choice = PumpChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
