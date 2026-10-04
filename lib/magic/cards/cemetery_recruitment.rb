module Magic
  module Cards
    CemeteryRecruitment = Sorcery("Cemetery Recruitment") do
      cost generic: 1, black: 1
    end

    class CemeteryRecruitment < Sorcery
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(target:)
        target.move_to_hand!
        trigger_effect(:draw_cards, player: controller) if target.type?("Zombie")
      end
    end
  end
end
