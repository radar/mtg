module Magic
  module Cards
    GandalfSparkStarter = Creature("Gandalf, Spark Starter") do
      cost generic: 4, red: 2
      legendary_creature_type("Avatar Wizard")
      keywords :reach
      power 4
      toughness 3
    end

    class GandalfSparkStarter < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        # "he deals 3 damage divided as you choose among one, two, or three targets."
        class DivideDamageChoice < Magic::Choice
          def choices = game.any_target

          def resolve!(distribution:)
            unless distribution.values.sum == 3 && distribution.values.all?(&:positive?)
              raise ArgumentError, "Gandalf must divide exactly 3 damage, at least 1 to each target"
            end
            raise ArgumentError, "at most three targets" if distribution.size > 3

            distribution.each do |target, damage|
              trigger_effect(:deal_damage, target: target, damage: damage)
            end
          end
        end

        def call
          game.choices.add(DivideDamageChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
