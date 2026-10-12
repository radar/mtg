module Magic
  module Cards
    GarruksHarbinger = Creature("Garruk's Harbinger") do
      cost generic: 1, green: 2
      creature_type "Beast"
      power 4
      toughness 3
    end

    class GarruksHarbinger < Creature
      KEYWORDS = [Keywords::HexproofFrom.new(:black)]

      # "Whenever this creature deals combat damage to a player or planeswalker, look at that many
      # cards from the top of your library. You may reveal a creature card or Garruk planeswalker
      # card from among them and put it into your hand. Put the rest on the bottom of your library
      # in a random order."
      class DamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && (event.target.is_a?(Magic::Player) || event.target.planeswalker?)
        end

        def call
          filter = ->(card) { card.creature? || (card.planeswalker? && card.type?("Garruk")) }
          game.add_choice(Magic::Choice::LookAtTopCards.new(actor: actor, amount: event.damage, filter: filter))
        end
      end

      def event_handlers = { Events::CombatDamageDealt => DamageTrigger }
    end
  end
end
