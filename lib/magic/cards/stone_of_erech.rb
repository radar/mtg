module Magic
  module Cards
    StoneOfErech = Artifact("Stone of Erech") do
      legendary_artifact
      cost generic: 1
    end

    class StoneOfErech < Artifact
      # "If a creature an opponent controls would die, exile it instead."
      class ExileInstead < ReplacementEffect
        def applies?(effect)
          !!effect.from&.battlefield? && effect.to.graveyard? && effect.target.creature? &&
            effect.target.controller != receiver.controller
        end

        def call(effect)
          Effects::ExilePermanent.new(source: receiver, target: effect.target)
        end
      end

      # "{2}, {T}, Sacrifice Stone of Erech: Exile target player's graveyard. Draw a card."
      class ExileGraveyardAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def single_target? = true

        def target_choices = game.players

        def resolve!(target:)
          target.graveyard.cards.to_a.dup.each(&:exile!)
          draw_card
        end
      end

      def replacement_effects = { Effects::MovePermanentZone => ExileInstead }

      def activated_abilities = [ExileGraveyardAbility]
    end
  end
end
