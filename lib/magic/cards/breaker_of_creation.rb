module Magic
  module Cards
    BreakerOfCreation = Creature("Breaker of Creation") do
      cost "{6}{C}{C}"
      creature_type "Eldrazi"
      keywords(
        *Mana::COLORS.map { |color| Keywords::HexproofFrom.new(color) },
        Keywords::Annihilator.new(2)
      )
      power 8
      toughness 4
    end

    class BreakerOfCreation < Creature
      # "When you cast this spell, you gain 1 life for each colorless permanent you control."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          amount = controller.permanents.count(&:colorless?)
          gain_life(amount) if amount.positive?
        end
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
