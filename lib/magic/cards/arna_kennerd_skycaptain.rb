module Magic
  module Cards
    ArnaKennerdSkycaptain = Creature("Arna Kennerüd, Skycaptain") do
      legendary_creature_type "Human Knight"
      cost "{2}{W}{U}{B}"
      keywords :flying, :lifelink
      power 4
      toughness 4
      ward discard: true
    end

    class ArnaKennerdSkycaptain < Creature
      # "Whenever a modified creature you control attacks, double the number of each kind of counter on it. Then for each
      # nontoken permanent attached to it, create a token that's a copy of that permanent attached to that creature."
      class AttacksTrigger < Magic::TriggeredAbility
        def should_perform?
          attacker = event.attacker
          attacker.controller == controller && attacker.modified?
        end

        def call
          attacker = event.attacker
          attacker.counters.map(&:class).uniq.each do |counter_type|
            attacker.add_counter(counter_type, amount: attacker.counters.of_type(counter_type).count)
          end
          game.settle!

          attacker.attachments.reject(&:token?).each do |attachment|
            copy_as_token(attachment.card).each { _1.attach_to!(attacker) }
          end
        end
      end

      def event_handlers
        super.merge(Events::CreatureAttacked => AttacksTrigger)
      end
    end
  end
end
