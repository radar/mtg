module Magic
  module Cards
    GatekeeperOfMalakir = Creature("Gatekeeper of Malakir") do
      cost black: 2
      creature_type("Vampire Warrior")
      kicker_cost black: 1
      power 2
      toughness 2
    end

    class GatekeeperOfMalakir < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          actor.kicked?
        end

        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def choices
            battlefield.controlled_by(@player).by_any_type("Creature")
          end

          def choice_amount = 1

          def resolve!(target:)
            target.sacrifice!
          end
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.players
          end

          def choice_amount = 1

          def resolve!(target:)
            choice = SacrificeChoice.new(actor: actor, player: target)
            game.choices.add(choice) if choice.choices.any?
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
