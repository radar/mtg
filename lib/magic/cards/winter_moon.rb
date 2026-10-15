module Magic
  module Cards
    WinterMoon = Artifact("Winter Moon") do
      cost generic: 2
    end

    class WinterMoon < Artifact
      # "Players can't untap more than one nonbasic land during their untap steps."
      # The first tapped nonbasic land stays free to untap; the rest stay tapped (the engine picks the land, since the
      # untap step has no decision point for the player).
      class LimitNonbasicLandUntapping < StaticAbility
        def cannot_untap_during_untap_step(permanents, _active_player)
          tapped_nonbasic_lands = permanents.select { _1.land? && !_1.basic_land? && _1.tapped? }
          tapped_nonbasic_lands.drop(1)
        end
      end

      def static_abilities = [LimitNonbasicLandUntapping]
    end
  end
end
