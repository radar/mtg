# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Beholding as an additional cost to cast the card (Tarkir: Dragonstorm, Lorwyn Eclipsed). To behold a
      # Dragon is to choose a Dragon you control or reveal a Dragon card from your hand.
      #
      #   As an additional cost to cast this spell, behold a Dragon or pay {1}.  -> additional_costs: Costs::Behold (or_mana)
      #   As an additional cost to cast this spell, behold a Dragon.               -> additional_costs: Costs::Behold
      #   As an additional cost to cast this spell, you may behold a Dragon.       -> kicker_cost: Costs::OptionalBehold
      #   You may cast this spell as though it had flash if you behold a Dragon as an additional cost to cast it.
      #                                                                            -> the same, with grants_flash: true
      #
      # The optional forms use the kicker plumbing (`Cast#pay_kicker(permanent_or_card)`), so "If a Dragon was
      # beheld, <effects>" is an ordinary "if this spell was kicked" effect (see EffectList). The "and exile it"
      # form (Champion of the Weird) isn't parsed.
      class BeholdCost < Data.define(:type, :mana, :optional, :flash)
        include Rule

        COST = "As an additional cost to cast ~, "
        TYPE = /(?<type>[A-Z][\w-]*)/
        REQUIRED = /\A#{COST}behold an? #{TYPE}(?: or pay (?<mana>(?:\{[^}]+\})+))?\.?\z/
        OPTIONAL = /\A#{COST}you may behold an? #{TYPE}\.?\z/
        FLASH = /\AYou may cast ~ as though it had flash if you behold an? #{TYPE} as an additional cost to cast it\.?\z/

        def self.parse(line)
          if (m = REQUIRED.match(line)) then build(m, mana: m[:mana] && ManaCost.parse(m[:mana]), optional: false, flash: false)
          elsif (m = OPTIONAL.match(line)) then build(m, mana: nil, optional: true, flash: false)
          elsif (m = FLASH.match(line)) then build(m, mana: nil, optional: true, flash: true)
          end
        end

        def self.build(match, **fields)
          new(type: match[:type], **fields) if Types::Creatures.values.include?(match[:type])
        end

        def body_source
          if optional
            <<~RUBY
              # You may behold a #{type} as an additional cost to cast this spell.
              def kicker_cost
                @behold_cost ||= Costs::OptionalBehold.new(self, type: #{type.inspect}#{', grants_flash: true' if flash})
              end
            RUBY
          else
            or_mana = ", or_mana: #{mana.inspect}" if mana
            <<~RUBY
              # As an additional cost to cast this spell, behold a #{type}#{' or pay mana' if mana}.
              def additional_costs
                [Costs::Behold.new(self, type: #{type.inspect}#{or_mana})]
              end
            RUBY
          end
        end
      end
    end
  end
end
