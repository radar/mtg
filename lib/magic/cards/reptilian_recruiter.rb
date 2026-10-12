module Magic
  module Cards
    ReptilianRecruiter = Creature("Reptilian Recruiter") do
      cost generic: 3, red: 2
      creature_type("Lizard Warrior")
      keywords :trample
      power 4
      toughness 2
    end

    class ReptilianRecruiter < Creature
      # When this creature enters, choose target creature. If that creature's power is 2 or less or if you
      # control another Lizard, gain control of that creature until end of turn, untap it, and it gains haste
      # until end of turn.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class StealChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 1

          def resolve!(target:)
            other_lizard = (battlefield.controlled_by(controller).creatures - [actor]).any? { _1.type?("Lizard") }
            return unless target.power <= 2 || other_lizard

            target.gain_control_until_eot!(controller)
            target.untap!
            trigger_effect(:grant_keyword, target: target, keyword: :haste)
          end
        end

        def call
          choice = StealChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
