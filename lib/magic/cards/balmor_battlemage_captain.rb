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
            pump(creature, 1, 0)
            give_keyword(creature, :trample)
          end
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
