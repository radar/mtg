module Magic
  module Cards
    class RestrictedOfficeLectureHall < Room
      class RestrictedOffice < Room::Door
        card_name "Restricted Office"
        cost generic: 2, white: 2

        # "When you unlock this door, destroy all creatures with power 3 or greater."
        when_unlocked do
          game.battlefield.creatures.select { _1.power >= 3 }.each { destroy(_1) }
        end
      end

      class LectureHall < Room::Door
        card_name "Lecture Hall"
        cost generic: 5, blue: 2

        # "Other permanents you control have hexproof."
        class HexproofGrant < Abilities::Static::KeywordGrant
          keyword_grants Keywords::HEXPROOF

          applicable_targets { source.controller.permanents.reject { _1 == source } }
        end

        def static_abilities = [HexproofGrant]
      end

      doors RestrictedOffice, LectureHall
    end
  end
end
