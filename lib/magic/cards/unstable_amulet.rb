module Magic
  module Cards
    UnstableAmulet = Artifact("Unstable Amulet") do
      cost generic: 1, red: 1
    end

    class UnstableAmulet < Artifact
      # When this artifact enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # Whenever you cast a spell from anywhere other than your hand, this artifact deals 1 damage to each opponent.
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && !event.cast_from_hand?
        end

        def call
          opponents.each { deal_damage(1, to: _1) }
        end
      end

      # {T}, Pay {E}{E}: Exile the top card of your library. You may play it until you exile another card with this
      # artifact.
      class ExileAbility < Magic::ActivatedAbility
        costs "{T}, Pay {E}{E}"

        def resolve!
          card = controller.library.first
          return unless card

          exile_target(card)
          game.play_permissions.grant_until_another_exiled_with(card:, player: controller, permanent: source)
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::SpellCast => SpellCastTrigger }

      def activated_abilities = [ExileAbility]
    end
  end
end
