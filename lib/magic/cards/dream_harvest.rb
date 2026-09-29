module Magic
  module Cards
    class DreamHarvest < Sorcery
      card_name "Dream Harvest"
      cost "{5}{U/B}{U/B}"

      # "Each opponent exiles cards from the top of their library until they have exiled cards with
      # total mana value 5 or greater this way. Until end of turn, you may cast cards exiled this
      # way without paying their mana costs."
      def resolve!
        caster = controller
        game.opponents(caster).each do |opponent|
          total = 0
          while total < 5 && (card = opponent.library.first)
            trigger_effect(:exile, target: card)
            total += card.mana_value
            game.play_permissions.grant_until_end_of_turn(card:, player: caster, free: true) unless card.land?
          end
        end
      end
    end
  end
end
