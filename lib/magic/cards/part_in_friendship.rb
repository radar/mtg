module Magic
  module Cards
    PartInFriendship = Enchantment("Part in Friendship") do
      cost generic: 4, green: 1
    end

    class PartInFriendship < Enchantment
      class CreatureDiesTrigger < TriggeredAbility::OncePerTurn
        def should_perform?
          you? && !event.permanent.token?
        end

        # OncePerTurn tracks the event's permanent, which here is the creature that died: track this enchantment.
        def triggered_this_turn? = actor.triggered_once_this_turn?(self.class)

        def mark_triggered_this_turn! = actor.trigger_once_this_turn!(self.class)

        def call
          library = controller.library
          found = library.find { _1.type?("Creature") }
          revealed = library.take_while { !_1.equal?(found) }
          trigger_effect(:reveal_cards, target: [*revealed, found].compact)
          # "If its mana value is less than or equal to the number of lands you control, put it onto the battlefield.
          # Otherwise, put it into your hand."
          if found && found.mana_value <= controller.lands.count
            found.resolve!
          else
            found&.move_to_hand!
          end
          revealed.shuffle.each do |card|
            library.remove(card)
            library.push(card)
          end
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => CreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
