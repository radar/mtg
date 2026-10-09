module Magic
  module Cards
    ThranduilsCompany = Creature("Thranduil's Company") do
      cost "{2}{G}{U}"
      creature_type "Elf Soldier"
      power 3
      toughness 4
    end

    class ThranduilsCompany < Creature
      # "As long as you control another Elf, you may play an additional land on each of your turns."
      def additional_lands_per_turn
        elves = game.battlefield.controlled_by(controller).select { _1.type?("Elf") && _1.card != self }
        elves.any? ? 1 : 0
      end

      # "Landfall -- Whenever a land you control enters, put two +1/+1 counters on target creature you control. It gains
      # vigilance until end of turn."
      class TargetChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
          trigger_effect(:grant_keyword, target: target, keyword: :vigilance)
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
