module Magic
  module Cards
    ProudPackRhino = Creature("Proud Pack-Rhino") do
      cost generic: 2, white: 1
      creature_type "Rhino"
      power 3
      toughness 3
    end

    class ProudPackRhino < Creature
      # When this creature enters, choose one — put a shield counter on target permanent; or proliferate.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ShieldChoice < Magic::Choice::Targeted
          def choices = battlefield.permanents

          def choice_amount = 1

          def resolve!(target:)
            add_counter "shield", to: target
          end
        end

        class ModeChoice < Magic::Choice
          def prompt = "Choose one: put a shield counter on target permanent, or proliferate."

          def modes
            {
              shield: "Put a shield counter on target permanent",
              proliferate: "Proliferate"
            }
          end

          def resolve!(mode:)
            case mode
            when :shield
              game.add_choice(ShieldChoice.new(actor: actor))
            when :proliferate
              proliferate
            else
              raise "Invalid mode chosen for Proud Pack-Rhino: #{mode}"
            end
          end
        end

        def call
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
