module Magic
  module Cards
    ValgavothTerrorEater = Creature("Valgavoth, Terror Eater") do
      cost generic: 6, black: 3
      legendary_creature_type "Elder Demon"
      keywords :flying, :lifelink
      ward sacrifice_nonland: 3
      power 9
      toughness 9
    end

    class ValgavothTerrorEater < Creature
      # "If a card you didn't control would be put into an opponent's graveyard from anywhere, exile it instead." The card is
      # remembered as exiled with Valgavoth (`Permanent#exiled_cards`).
      class ExileInsteadOfGraveyard < ReplacementEffect
        def applies?(effect)
          return false unless effect.to.graveyard? && effect.to.owner != receiver.controller
          return false if effect.target.is_a?(Permanent) && effect.target.token?

          controller_of(effect.target) != receiver.controller
        end

        def call(effect)
          card = effect.target.is_a?(Permanent) ? effect.target.card : effect.target
          receiver.exiled_cards << card
          effect.target.is_a?(Permanent) ? Effects::ExilePermanent.new(source: receiver, target: effect.target) : Effects::ExileCard.new(source: receiver, target: effect.target)
        end

        private

        def controller_of(target) = target.controller
      end

      # "During your turn, you may play cards exiled with Valgavoth. If you cast a spell this way, pay life equal to its mana
      # value rather than pay its mana cost." Cast the spell with `pay_life: true`.
      class PlayExiledCards < StaticAbility
        def permits_casting_from_exile?(card, player)
          playable?(card, player)
        end

        def may_pay_life_for?(card, player)
          playable?(card, player) && !card.land? && player.life >= card.mana_value
        end

        private

        def playable?(card, player)
          player == controller && game.current_turn.active_player == controller &&
            card.zone&.exile? && @source.exiled_cards.include?(card)
        end
      end

      def replacement_effects = { Effects::MoveCardZone => ExileInsteadOfGraveyard, Effects::MovePermanentZone => ExileInsteadOfGraveyard }
      def static_abilities = [PlayExiledCards]
    end
  end
end
