module Magic
  module Cards
    BalmorBattlemageCaptain = Creature("Balmor, Battlemage Captain") do
      cost blue: 1, red: 1
      legendary_creature_type("Bird Wizard")
      keywords :flying
      power 1
      toughness 3
    end

    class BalmorBattlemageCaptain < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.type?("Instant") || spell.type?("Sorcery"))
        end

        def call
          battlefield.controlled_by(controller).creatures.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 0)
            trigger_effect(:grant_keyword, target: creature, keyword: :trample)
          end
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
