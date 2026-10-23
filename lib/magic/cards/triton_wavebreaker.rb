module Magic
  module Cards
    TritonWavebreaker = Creature("Triton Wavebreaker") do
      enchantment_creature_type("Merfolk Wizard")
      cost blue: 1
      keywords :prowess
      bestow Costs::Mana.new(generic: 1, blue: 1)
      power 1
      toughness 1
    end

    class TritonWavebreaker < Creature
      # "Enchanted creature gets +1/+1 and has prowess."
      def power_modification = 1

      def toughness_modification = 1

      def keyword_grants = [Keywords::PROWESS]

      # The prowess the enchanted creature has: it is the creature's triggered ability, so it reads the host's controller.
      class EnchantedCreatureProwess < TriggeredAbility::SpellCast
        def should_perform?
          host = actor.attached_to
          actor.bestowed_now? && event.player == host.controller && !spell.creature?
        end

        def call
          host = actor.attached_to
          pump host, 1, 1, source: host
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => EnchantedCreatureProwess }) { |_, old, new| [*old, *new] }
    end
  end
end
