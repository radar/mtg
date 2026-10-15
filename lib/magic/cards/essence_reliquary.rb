module Magic
  module Cards
    EssenceReliquary = Artifact("Essence Reliquary") do
      cost generic: 2, white: 1
    end

    class EssenceReliquary < Artifact
      # "{T}: Return another target permanent you control and all Auras you control attached to it to their owner's
      # hand. Activate only during your turn."
      class ReturnAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices = battlefield.controlled_by(controller).permanents - [source]

        def requirements_met? = game.current_turn.active_player == controller

        def resolve!(target:)
          auras = target.attachments.select { _1.controller == controller && _1.card.is_a?(Cards::Aura) }
          auras.each { bounce(_1) }
          bounce(target)
        end
      end

      def activated_abilities = [ReturnAbility]
    end
  end
end
