module Magic
  module Cards
    SauronTheLidlessEye = Creature("Sauron, the Lidless Eye") do
      cost "{3}{B}{R}"
      legendary_creature_type "Avatar Horror"
      power 4
      toughness 4
    end

    class SauronTheLidlessEye < Creature
      # "When Sauron enters, gain control of target creature an opponent controls until end of turn. Untap it. It gains
      # haste until end of turn." The target is mandatory.
      class StealChoice < Magic::Choice::Targeted
        def choices = battlefield.not_controlled_by(controller).creatures

        def choice_amount = 1

        def resolve!(target:)
          target.gain_control_until_eot!(controller)
          target.untap!
          give_keyword(target, :haste)
        end

        def decline!
          resolve!(target: choices.first)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = StealChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "{1}{B}{R}: Creatures you control get +2/+0 until end of turn. Each opponent loses 2 life."
      class RallyAbility < Magic::ActivatedAbility
        costs "{1}{B}{R}"

        def resolve!
          controller.creatures.each { pump _1, 2, 0 }
          game.opponents(controller).each { lose_life _1, 2 }
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [RallyAbility]
    end
  end
end
