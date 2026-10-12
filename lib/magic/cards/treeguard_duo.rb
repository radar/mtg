module Magic
  module Cards
    TreeguardDuo = Creature("Treeguard Duo") do
      cost generic: 3, green: 1
      creature_type("Frog Rabbit")
      power 3
      toughness 4
    end

    class TreeguardDuo < Creature
      # When this creature enters, until end of turn, target creature you control gains vigilance and gets +X/+X,
      # where X is the number of creatures you control.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            x = choices.count
            trigger_effect(:grant_keyword, target: target, keyword: :vigilance)
            pump(target, x, x)
          end
        end

        def call
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
