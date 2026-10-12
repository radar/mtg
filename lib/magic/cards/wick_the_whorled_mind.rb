module Magic
  module Cards
    WickTheWhorledMind = Creature("Wick, the Whorled Mind") do
      legendary_creature_type "Rat Warlock"
      cost generic: 3, black: 1
      power 2
      toughness 4
    end

    class WickTheWhorledMind < Creature
      # Whenever Wick or another Rat you control enters, create a 1/1 black Snail creature token if you don't
      # control a Snail. Otherwise, put a +1/+1 counter on a Snail you control.
      class RatEnters < TriggeredAbility::EnterTheBattlefield
        class SnailChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.select { _1.type?("Snail") }

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target)
          end
        end

        def should_perform? = under_your_control? && event.permanent.type?("Rat")

        def call
          if battlefield.controlled_by(controller).creatures.any? { _1.type?("Snail") }
            game.add_choice(SnailChoice.new(actor: actor))
          else
            trigger_effect(:create_token, token_class: Tokens::Snail)
          end
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => RatEnters)

      # {U}{B}{R}, Sacrifice a Snail: Wick deals damage equal to the sacrificed creature's power to each
      # opponent. Then draw cards equal to the sacrificed creature's power.
      class SnailAbility < Magic::ActivatedAbility
        costs "{U}{B}{R}, Sacrifice a Snail"

        def resolve!
          power = source.state[:last_sacrificed]&.power.to_i
          game.opponents(controller).each { |opponent| deal_damage(power, to: opponent) }
          draw_cards(power) if power.positive?
        end
      end

      def activated_abilities = [SnailAbility]
    end
  end
end
