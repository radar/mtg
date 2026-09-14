module Magic
  module Cards
    RoilingVortex = Enchantment("Roiling Vortex") do
      cost generic: 1, red: 1
    end

    class RoilingVortex < Enchantment
      class UpkeepTrigger < TriggeredAbility
        def call
          actor.trigger_effect(:deal_damage, damage: 1, target: event.player)
        end
      end

      class FreeSpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          mana_cost.zero?
        end

        def call
          actor.trigger_effect(:deal_damage, damage: 5, target: event.player)
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger,
          Events::SpellCast => FreeSpellTrigger
        }
      end

      class PreventOpponentLifeGain < ReplacementEffect
        def applies?(effect)
          receiver.prevent_opponent_lifegain_turn == receiver.game.current_turn.number &&
            receiver.opponents.include?(effect.target)
        end

        def call(effect)
          Effects::GainLife.new(source: receiver, target: effect.target, life: 0)
        end
      end

      def replacement_effects
        {
          Effects::GainLife => PreventOpponentLifeGain
        }
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{R}"

        def resolve!
          source.prevent_opponent_lifegain_turn = game.current_turn.number
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
