module Magic
  module Cards
    RetchedWretch = Creature("Retched Wretch") do
      cost generic: 2, black: 1
      creature_type("Goblin")
      power 4
      toughness 2
    end

    class RetchedWretch < Creature
      # "When this creature dies, if it had a -1/-1 counter on it, return it to the
      # battlefield under its owner's control and it loses all abilities." The permanent
      # that died still knows its counters (last known information). If the trigger runs
      # before the card itself reaches the graveyard, it waits for it there.
      class DiesTrigger < TriggeredAbility::Death
        def should_perform?
          actor.counters.of_type(Counters::Minus1Minus1).any? && !actor.token? && !actor.copy?
        end

  def call
    card = actor.card
    come_back = lambda do |zone|
      returned = Permanent.resolve(game:, card:, owner: card.owner, from_zone: zone, cast: false)
      returned.lose_all_abilities!
    end

    # With queued triggers the card is normally in the graveyard by the time this resolves.
    return come_back.call(card.zone) if card.zone&.graveyard?

    OnCardMoved.listen(game:, card:) { |zone| come_back.call(zone) if zone.graveyard? }
  end
end

      def death_triggers = [DiesTrigger]
    end
  end
end
