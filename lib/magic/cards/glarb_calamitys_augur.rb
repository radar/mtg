module Magic
  module Cards
    GlarbCalamitysAugur = Creature("Glarb, Calamity's Augur") do
      legendary_creature_type "Frog Wizard Noble"
      cost black: 1, green: 1, blue: 1
      keywords :deathtouch
      power 2
      toughness 4
    end

    class GlarbCalamitysAugur < Creature
      # You may look at the top card of your library any time. (The top card is visible to its controller.)
      # You may play lands and cast spells with mana value 4 or greater from the top of your library.
      class TopOfLibrary < StaticAbility
        attr_reader :source

        def permits_casting_from_top?(card, player)
          player == source.controller && (card.land? || card.mana_value >= 4)
        end
      end

      def static_abilities = [TopOfLibrary]

      # {T}: Surveil 2.
      class SurveilAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          game.choices.add(Magic::Choice::Surveil.new(actor: source, amount: 2))
        end
      end

      def activated_abilities = [SurveilAbility]
    end
  end
end
