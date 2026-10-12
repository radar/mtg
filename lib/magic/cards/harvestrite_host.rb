module Magic
  module Cards
    HarvestriteHost = Creature("Harvestrite Host") do
      cost generic: 2, white: 1
      creature_type("Rabbit Citizen")
      power 3
      toughness 3
    end

    class HarvestriteHost < Creature
      # Whenever this creature or another Rabbit you control enters, target creature you control gets +1/+0 until
      # end of turn. Then draw a card if this is the second time this ability has resolved this turn.
      class RabbitEnters < TriggeredAbility::EnterTheBattlefield
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, power: 1, toughness: 0, target: target, until_eot: true)
            resolutions = (actor.state[:resolutions] ||= Hash.new(0))
            turn = game.current_turn.number
            resolutions[turn] += 1
            trigger_effect(:draw_cards, number_to_draw: 1) if resolutions[turn] == 2
          end
        end

        def should_perform? = under_your_control? && event.permanent.type?("Rabbit")

        def call
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => RabbitEnters)
    end
  end
end
