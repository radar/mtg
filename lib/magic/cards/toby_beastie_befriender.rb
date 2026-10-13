module Magic
  module Cards
    TobyBeastieBefriender = Creature("Toby, Beastie Befriender") do
      cost generic: 2, white: 1
      legendary_creature_type "Human Wizard"
      power 1
      toughness 1
    end

    class TobyBeastieBefriender < Creature
      # A 4/4 white Beast creature token with "This token can't attack or block alone."
      BeastToken = Token.create "Beast" do
        creature_type "Beast"
        colors :white
        power 4
        toughness 4

        def cant_attack_alone? = true
        def cant_block_alone? = true
      end

      # "When Toby enters, create a 4/4 white Beast creature token with 'This token can't attack or block alone.'"
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          create_token(token:TobyBeastieBefriender::BeastToken)
        end
      end

      # "As long as you control four or more creature tokens, creature tokens you control have flying."
      class TokensFly < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING

        conditions { source.controller.creatures.count(&:token?) >= 4 }
        applicable_targets { source.controller.creatures.select(&:token?) }
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [TokensFly]
    end
  end
end
