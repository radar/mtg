module Magic
  module Cards
    ArcaneSignet = Artifact("Arcane Signet") do
      cost generic: 2
    end

    class ArcaneSignet < Artifact
      class ManaAbility < Magic::TapManaAbility
        def choices = controller.commander.color_identity
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
