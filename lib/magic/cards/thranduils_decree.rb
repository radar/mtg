module Magic
  module Cards
    ThranduilsDecree = Instant("Thranduil's Decree") do
      cost generic: 4, blue: 2
    end

    class ThranduilsDecree < Instant
      def single_target? = true

      def target_choices
        game.stack.spells.reject { |spell| spell.card == self }
      end

      # "Counter target spell. If a permanent spell is countered this way, exile it instead of putting it into its
      # owner's graveyard. You may cast that card without paying its mana cost for as long as it remains exiled."
      def resolve!(target:)
        spell_card = target.card
        return unless spell_card.can_be_countered?

        if spell_card.permanent?
          game.stack.remove(target)
          game.notify!(Events::SpellCountered.new(spell: spell_card, player: target.player))
          spell_card.exile!
          game.play_permissions.grant_free_while_exiled(card: spell_card, player: controller)
        else
          trigger_effect(:counter_spell, target: target)
        end
      end
    end
  end
end
