module Magic
  module Cards
    NimbleHobbit = Creature("Nimble Hobbit") do
      cost generic: 1, white: 1
      creature_type "Halfling Peasant"
      power 1
      toughness 3
    end

    class NimbleHobbit < Creature
      MANA = { generic: 2, white: 1 }.freeze
      PAY = :pay

      # "When you do, tap target creature an opponent controls."
      class TapChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.reject { _1.controller == controller }

        def choice_amount = 1

        def resolve!(target:)
          tap_permanent(target)
        end

        def decline! = nil
      end

      # "...you may sacrifice a Food or pay {2}{W}." Pick a Food (`resolve!(sacrifice: food)`) or pay the mana
      # (`resolve!(pay: true)`, optionally with `payment:`); declining (`game.skip_choice!`) does nothing. Either way,
      # the reflexive tap trigger follows.
      class CostChoice < Magic::Choice
        def prompt = "Sacrifice a Food or pay {2}{W} to tap target creature an opponent controls?"

        def foods = controller.permanents.select { _1.type?("Food") }

        def can_pay? = Costs::Mana.new(MANA.dup).can_pay?(controller)

        def choices = foods + (can_pay? ? [PAY] : [])

        def resolve!(sacrifice: nil, pay: false, payment: nil)
          if sacrifice
            raise ArgumentError, "choose one of your Foods" unless foods.include?(sacrifice)

            sacrifice.sacrifice!
          elsif pay
            cost = Costs::Mana.new(MANA.dup)
            raise ArgumentError, "can't pay {2}{W}" unless cost.can_pay?(controller)

            if payment
              cost.pay!(player: controller, payment: payment)
            else
              cost.auto_pay(player: controller)
              cost.finalize!(controller)
            end
          else
            raise ArgumentError, "sacrifice a Food or pay {2}{W}"
          end

          tap_choice = TapChoice.new(actor: actor)
          game.add_choice(tap_choice) if tap_choice.choices.any?
        end

        def decline! = nil
      end

      # "Whenever this creature attacks, you may sacrifice a Food or pay {2}{W}. When you do, tap target creature an
      # opponent controls."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          choice = CostChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
