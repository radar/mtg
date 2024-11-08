module Magic
  module Cards
    ArchonOfSunsGrace = Creature("Archon of Sun's Grace") do
      cost generic: 2, white: 2
      power 3
      toughness 4
      creature_type "Archon"
      keywords :flying, :lifelink
    end

    class ArchonOfSunsGrace < Creature
      PegasusToken = Token.create "Pegasus" do
        creature_type "Pegasus"
        power 2
        toughness 2
        colors :white
        keywords :flying
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          # Whenever an enchantment enters the battlefield under your control ...
          enchantment? && under_your_control?
        end

        def call
          actor.create_token(token_class: PegasusToken)
        end
      end

      class LifelinkAddition < Abilities::Static::KeywordGrant
        keyword_grants Cards::Keywords::LIFELINK
        applicable_targets { source.controller.creatures.by_type("Pegasus") }
      end

      def static_abilities = [LifelinkAddition]

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger
        }
      end
    end
  end
end
