module Magic
  module Cards
    class FestivalOfEmbers < Enchantment
      card_name "Festival of Embers"
      cost generic: 4, red: 1

      # During your turn, you may cast instant and sorcery spells from your graveyard by paying 1 life in
      # addition to their other costs.
      class GraveyardCasting < StaticAbility
        attr_reader :source

        def permits_casting_from_graveyard?(card, player)
          player == source.controller && card.owner == player && (card.instant? || card.sorcery?) &&
            source.game.current_turn.active_player == player
        end

        def additional_cost_for(card, player)
          return unless card.zone&.graveyard? && permits_casting_from_graveyard?(card, player)

          Costs::PayLifeAdditional.new(card, amount: 1)
        end
      end

      def static_abilities = [GraveyardCasting]

      # If a card or token would be put into your graveyard from anywhere, exile it instead.
      class ExileInsteadOfGraveyard < ReplacementEffect
        def applies?(effect)
          effect.to.respond_to?(:graveyard?) && effect.to.graveyard? && effect.to.owner == receiver.controller
        end

        def call(effect)
          if effect.target.is_a?(Permanent)
            Effects::ExilePermanent.new(source: receiver, target: effect.target)
          else
            Effects::ExileCard.new(source: receiver, target: effect.target)
          end
        end
      end

      def replacement_effects
        { Effects::MovePermanentZone => ExileInsteadOfGraveyard, Effects::MoveCardZone => ExileInsteadOfGraveyard }
      end

      # {1}{R}: Sacrifice this enchantment.
      class SacrificeAbility < Magic::ActivatedAbility
        costs "{1}{R}"

        def resolve!
          source.sacrifice!
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
