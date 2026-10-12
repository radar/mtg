module Magic
  module Cards
    BalinLoremaster = Creature("Balin, Loremaster") do
      legendary_creature_type "Dwarf Bard"
      cost generic: 3, red: 2
      power 4
      toughness 4
    end

    class BalinLoremaster < Creature
      # "You may discard your hand. Draw X cards, where X is the number of cards discarded this way. If you have an
      # enduring story, Balin deals X damage to each opponent."
      class DiscardHandChoice < Magic::Choice::May
        def resolve!
          discarded = [*controller.hand.cards].dup
          discarded.each(&:discard!)
          return if discarded.empty?

          trigger_effect(:draw_cards, player: controller, number_to_draw: discarded.count)
          return unless Magic::Storied.enduring_story?(controller)

          game.opponents(controller).each do |opponent|
            trigger_effect(:deal_damage, target: opponent, damage: discarded.count)
          end
        end
      end

      # "Whenever Balin or another Dwarf you control enters, ..."
      class EntersTrigger < TriggeredAbility
        def should_perform?
          Magic::Storied.check(controller)
          permanent = event.permanent
          permanent.controller == controller && (permanent == actor || permanent.type?("Dwarf"))
        end

        def call
          game.choices.add(DiscardHandChoice.new(actor:))
        end
      end

      def event_handlers
        super.merge({ Events::EnteredTheBattlefield => EntersTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
