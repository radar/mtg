module Magic
  module Cards
    TurnToSlag = Sorcery("Turn to Slag") do
      cost generic: 3, red: 2
    end

    class TurnToSlag < Sorcery
      def target_choices = battlefield.creatures

      # "Turn to Slag deals 5 damage to target creature. Destroy all Equipment attached to that
      # creature." The Equipment is found before the damage, since the creature may die from it.
      def resolve!(target:)
        equipment = target.attachments.select { |attachment| attachment.type?("Equipment") }
        trigger_effect(:deal_damage, target:, damage: 5)
        equipment.each(&:destroy!)
      end
    end
  end
end
