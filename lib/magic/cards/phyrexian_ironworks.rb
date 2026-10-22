module Magic
  module Cards
    PhyrexianIronworks = Artifact("Phyrexian Ironworks") do
      cost generic: 2, red: 1
    end

    class PhyrexianIronworks < Artifact
      GolemToken = Token.create "Phyrexian Golem" do
        artifact_creature_type "Phyrexian Golem"
        power 3
        toughness 3
      end

      # Whenever you attack, you get {E}.
      class AttackTrigger < TriggeredAbility::YouAttack
        def call
          gain_energy 1
        end
      end

      # {T}, Pay {E}{E}{E}: Create a 3/3 colorless Phyrexian Golem artifact creature token. Activate only as a sorcery.
      class GolemAbility < Magic::ActivatedAbility
        costs "{T}, Pay {E}{E}{E}"
        activate_only_as_sorcery

        def resolve!
          create_token(token: GolemToken)
        end
      end

      def event_handlers = super.merge(AttackTrigger.handlers)

      def activated_abilities = [GolemAbility]
    end
  end
end
