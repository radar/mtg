module Magic
  module Cards
    LindblumIndustrialRegency = Card("Lindblum, Industrial Regency") do
      type T::Land, T::Lands::Town
    end

    class LindblumIndustrialRegency < Card
      adventure generic: 2, red: 1

      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      def activated_abilities = [ManaAbility]

      def adventure_resolve!(**)
        trigger_effect(:create_token, token_class: WizardToken)
      end

      class WizardToken < Token
        token_name "Wizard"
        creature_type "Wizard"
        power 0
        toughness 1
        colors :black

        class DamageTrigger < TriggeredAbility::SpellCast
          def should_perform?
            you? && !spell.creature?
          end

          def call
            opponents.each { |opponent| trigger_effect(:deal_damage, damage: 1, target: opponent) }
          end
        end

        def event_handlers
          { Events::SpellCast => DamageTrigger }
        end
      end
    end
  end
end
