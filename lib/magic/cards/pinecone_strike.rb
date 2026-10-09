module Magic
  module Cards
    class PineconeStrike < Instant
      card_name "Pinecone Strike"
      cost generic: 1, red: 1

      # Pinecone Strike deals 3 damage to target creature. If that creature would die this turn, exile it instead.
      class Damage < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 3)
          target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
        end
      end

      # Destroy target artifact token.
      class DestroyToken < Mode
        def target_choices = battlefield.artifacts.select(&:token?)

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      modes Damage, DestroyToken
      choose_modes 1..2
    end
  end
end
