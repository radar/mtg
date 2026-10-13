module Magic
  module Cards
    class PineconeStrike < Instant
      card_name "Pinecone Strike"
      cost generic: 1, red: 1

      # Pinecone Strike deals 3 damage to target creature. If that creature would die this turn, exile it instead.
      class Damage < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          deal_damage(3, to: target)
          target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
        end
      end

      # Destroy target artifact token.
      class DestroyToken < Mode
        def target_choices = battlefield.artifacts.select(&:token?)

        def resolve!(target:)
          destroy(target)
        end
      end

      modes Damage, DestroyToken
      choose_modes 1..2
    end
  end
end
