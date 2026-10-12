module Magic
  class TriggeredAbility
    # Enduring (Duskmourn): "When this permanent dies, if it was a creature, return it to the battlefield under its
    # owner's control. It's an enchantment. (It's not a creature.)" Use via `def death_triggers = [EnduringReturn]`.
    class EnduringReturn < Death
      def should_perform?
        event.permanent == actor && actor.creature?
      end

      def call
        card = actor.card
        return unless card.zone&.graveyard?

        returned = card.resolve!(controller: card.owner)
        return unless returned.is_a?(Permanent)

        returned.remove_types(T::Creature, until_eot: false)
        returned.add_types(T::Enchantment, until_eot: false)
        returned.apply_continuous_effects!
      end
    end
  end
end
