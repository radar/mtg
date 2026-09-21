module Magic
  class Game
    # Rule 704: state-based actions.
    #
    # `perform!` runs a single pass over every rule and returns true if any of them
    # changed the game. `Game#check_state_based_actions!` repeats passes until one changes nothing.
    #
    # Rules that need a player decision (the legend rule) queue a `Choice` instead of acting. Queuing a
    # choice does not count as a change, so the loop still terminates.
    class StateBasedActions
      POISON_COUNTERS_TO_LOSE = 10

      attr_reader :game

      def initialize(game:)
        @game = game
      end

      def perform!
        changed = [
          make_players_lose,
          put_zero_toughness_creatures_into_graveyard,
          destroy_lethally_damaged_creatures,
          put_zero_loyalty_planeswalkers_into_graveyard,
          put_illegally_attached_auras_into_graveyard,
          unattach_illegally_attached_equipment,
          annihilate_counters,
          remove_tokens_from_other_zones,
        ].any?

        queue_legend_rule_choices
        changed
      end

      private

      # Rules 704.5a, 704.5b and 704.5c: 0 or less life, drew from an empty library, or 10+ poison counters.
      def make_players_lose
        losers = game.players.reject(&:lost?).select do |player|
          player.life <= 0 ||
            player.drew_from_empty_library? ||
            player.counters.of_type(Counters::Poison).count >= POISON_COUNTERS_TO_LOSE
        end
        losers.each(&:lose!)
        losers.any?
      end

      # Rule 704.5f: toughness 0 or less. Indestructible does not help here.
      def put_zero_toughness_creatures_into_graveyard
        creatures = game.battlefield.creatures.select { |creature| creature.toughness <= 0 }
        creatures.each(&:put_into_graveyard!)
        creatures.any?
      end

      # Rules 704.5g and 704.5h: lethal damage, or damage from a deathtouch source.
      # These destroy the creature, so an indestructible one survives; `destroy!` reports
      # whether it actually destroyed anything, which is what keeps an indestructible
      # creature from looking like a change on every pass.
      def destroy_lethally_damaged_creatures
        game.battlefield.creatures.select(&:lethally_damaged?).map(&:destroy!).any?
      end

      # Rule 704.5i
      def put_zero_loyalty_planeswalkers_into_graveyard
        planeswalkers = game.battlefield.planeswalkers.select { |planeswalker| planeswalker.loyalty <= 0 }
        planeswalkers.each(&:put_into_graveyard!)
        planeswalkers.any?
      end

      # Rule 704.5m: an Aura attached to nothing, or to something no longer on the battlefield.
      # Enchant restrictions (e.g. "enchant creature") are not re-checked.
      def put_illegally_attached_auras_into_graveyard
        auras = game.battlefield.permanents.select do |permanent|
          aura?(permanent) && !attached_to_legal_host?(permanent)
        end
        auras.each(&:put_into_graveyard!)
        auras.any?
      end

      # Rule 704.5n: Equipment attached to a non-creature or to nothing becomes unattached but stays on the battlefield.
      def unattach_illegally_attached_equipment
        equipment = game.battlefield.permanents.select do |permanent|
          equipment?(permanent) &&
            permanent.attached_to &&
            !(attached_to_legal_host?(permanent) && permanent.attached_to.creature?)
        end
        equipment.each(&:detach!)
        equipment.any?
      end

      # Rule 704.5q: +1/+1 and -1/-1 counters on the same permanent cancel out in pairs.
      def annihilate_counters
        permanents = game.battlefield.permanents.select do |permanent|
          permanent.counters.of_type(Counters::Plus1Plus1).any? &&
            permanent.counters.of_type(Counters::Minus1Minus1).any?
        end

        permanents.each do |permanent|
          pairs = [
            permanent.counters.of_type(Counters::Plus1Plus1).count,
            permanent.counters.of_type(Counters::Minus1Minus1).count,
          ].min
          permanent.take_counters!(Counters::Plus1Plus1, amount: pairs)
          permanent.take_counters!(Counters::Minus1Minus1, amount: pairs)
        end
        permanents.any?
      end

      # Rule 704.5d: a token in a zone other than the battlefield ceases to exist.
      def remove_tokens_from_other_zones
        zones = game.players.flat_map { |player| [player.hand, player.library, player.graveyard, player.exile] }
        zones << game.exile

        removed = zones.flat_map do |zone|
          zone.cards.select { |card| card&.token? }.each { |token| zone.remove(token) }
        end
        removed.any?
      end

      # Rule 704.5j: legend rule.
      def queue_legend_rule_choices
        pending = game.choices.grep(Choice::LegendRule).flat_map(&:permanents)

        game.battlefield.permanents
          .select(&:legendary?)
          .group_by { |permanent| [permanent.controller, permanent.name] }
          .each do |(controller, _name), permanents|
            next if permanents.size < 2 || permanents.intersect?(pending)

            game.add_choice(Choice::LegendRule.new(player: controller, permanents: permanents))
          end
      end

      # Aura and Equipment cards declare their type line as a single string ("Enchantment -- Aura"),
      # so a permanent's `types` holds that whole string rather than a separate "Aura" entry.
      # Check the card class as well as the type list.
      def aura?(permanent)
        permanent.card.is_a?(Cards::Aura) || permanent.type?("Aura")
      end

      def equipment?(permanent)
        permanent.card.is_a?(Cards::Equipment) || permanent.type?("Equipment")
      end

      # An attachment's host is legal while it is a player (e.g. a Curse) or still on the battlefield.
      def attached_to_legal_host?(permanent)
        host = permanent.attached_to
        !host.nil? && (host.player? || !host.zone.nil?)
      end
    end
  end
end
