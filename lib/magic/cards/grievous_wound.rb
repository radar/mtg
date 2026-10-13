module Magic
  module Cards
    GrievousWound = Aura("Grievous Wound") do
      cost generic: 3, black: 2
    end

    class GrievousWound < Aura
      enchant :player

      def target_choices
        game.players
      end

      # "Enchanted player can't gain life."
      class NoLifeGain < StaticAbility
        def prevents_life_gain?(player) = player == @source.attached_to
      end

      def static_abilities = [NoLifeGain]

      # "Whenever enchanted player is dealt damage, they lose half their life, rounded up."
      class DamagedTrigger < TriggeredAbility
        def should_perform?
          event.target == actor.attached_to && event.damage.positive?
        end

        def call
          player = actor.attached_to
          lose_life(player, (player.life / 2.0).ceil)
        end
      end

      def event_handlers = { Events::DamageDealt => DamagedTrigger }
    end
  end
end
