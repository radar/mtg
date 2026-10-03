module Magic
  module Cards
    KomaWorldEater = Creature("Koma, World-Eater") do
      cost generic: 3, green: 2, blue: 2
      legendary_creature_type("Serpent")
      cant_be_countered
      keywords :trample
      ward generic: 4
      power 8
      toughness 12
    end

    class KomaWorldEater < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        KomasCoilToken = Token.create "Koma's Coil" do
          creature_type "Serpent"
          power 3
          toughness 3
          colors :blue
        end

        def call
          trigger_effect(:create_token, token_class: KomasCoilToken, amount: 4)
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
