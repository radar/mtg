module Magic
  module Cards
    InfernalCaptor = Creature("Infernal Captor") do
      cost generic: 3, red: 1
      creature_type "Devil Rogue"
      power 3
      toughness 3
    end

    class InfernalCaptor < Creature
      # When this creature exploits a creature, gain control of target artifact or creature until end of turn.
      # Untap that permanent. It gains haste until end of turn.
      class StealChoice < Magic::Choice::Targeted
        def choices = battlefield.permanents.select { _1.creature? || _1.type?("Artifact") }

        def choice_amount = 1

        def resolve!(target:)
          target.gain_control_until_eot!(controller)
          target.untap!
          give_keyword(target, :haste)
        end
      end

      # Exploit: "When this creature enters, you may sacrifice a creature." It may sacrifice itself.
      class ExploitChoice < Magic::Choice::SacrificePermanent
        def initialize(actor:)
          super(actor: actor, type: "Creature", other: false)
        end

        def prompt = "Exploit: sacrifice a creature?"

        def resolve!(sacrifice: nil)
          super
          game.add_choice(StealChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          game.add_choice(ExploitChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
