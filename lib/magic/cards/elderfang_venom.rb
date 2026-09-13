module Magic
  module Cards
    ElderfangVenom = Enchantment("Elderfang Venom") do
      cost "{2}{B}{G}"
    end

    class ElderfangVenom < Enchantment
      class DeathtouchGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH

        applicable_targets { your.creatures.attacking.select { |creature| creature.type?("Elf") } }
      end

      class ElfDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller && event.permanent.type?("Elf")
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:lose_life, target: opponent, life: 1) }
          actor.trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def static_abilities = [DeathtouchGrant]

      def event_handlers
        { Events::CreatureDied => ElfDiedTrigger }
      end
    end
  end
end
