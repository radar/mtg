# frozen_string_literal: true

module Magic
  # Renders a CardParser::Result as Ruby source for lib/magic/cards/.
  class CardGenerator
    def self.snake_name(name)
      name.downcase.gsub(/[^a-z0-9\s]/, "").split.join("_")
    end

    def self.const_name(name)
      name.gsub(/[^A-Za-z0-9\s]/, "").split.map(&:capitalize).join
    end

    def self.generate(result)
      new(result).generate
    end

    def initialize(result)
      @result = result
    end

    def generate
      raise CardParser::UnsupportedCard, "only creatures supported" unless @result.creature?

      lines = []
      lines << "cost #{cost_args}" if @result.mana_cost.any?
      lines << "#{creature_type_method}(#{@result.subtypes.join(' ').inspect})" if @result.subtypes.any?
      lines.concat(@result.rules.flat_map(&:dsl_lines))
      lines << "power #{@result.power}"
      lines << "toughness #{@result.toughness}"
      body = lines.map { |l| "      #{l}\n" }.join
      const = self.class.const_name(@result.name)

      <<~RUBY
        module Magic
          module Cards
            #{const} = Creature(#{@result.name.inspect}) do
        #{body.chomp}
            end
        #{ability_class(const)}  end
        end
      RUBY
    end

    private

    # Nested classes must live in a class reopening, not the DSL block.
    def ability_class(const)
      hooked = @result.rules.select(&:hook)
      return "" if hooked.empty?

      sections = CardParser::Rule::HOOKS.filter_map { |hook| hook_section(hook, hooked.select { _1.hook == hook }) }
      "\n    class #{const} < Creature\n#{sections.map { indent(_1) }.join("\n\n")}\n    end\n"
    end

    # The nested classes for one hook plus the `def hook = [...]` line.
    def hook_section(hook, rules)
      return if rules.empty?

      seen = Hash.new(0)
      totals = rules.map(&:class_base_name).tally
      named = rules.map do |rule|
        base = rule.class_base_name
        [rule, totals[base] > 1 ? "#{base}#{seen[base] += 1}" : base]
      end
      classes = named.map { |rule, name| rule.class_source(name) }
      (classes + [hook_definition(hook, named)]).join("\n")
    end

    # Static and activated abilities are lists; event handlers map event => ability.
    def hook_definition(hook, named)
      return "def #{hook} = [#{named.map(&:last).join(', ')}]\n" unless hook == :event_handlers

      events = named.map { |rule, _| rule.handled_event }
      raise CardParser::UnsupportedCard, "two rules handle #{events.tally.key(2)}" if events.uniq.size < events.size

      pairs = named.map { |rule, name| "#{rule.handled_event} => #{name}" }
      "def event_handlers = { #{pairs.join(', ')} }\n"
    end

    def indent(source)
      source.lines.map { |line| line.strip.empty? ? line : "      #{line}" }.join.chomp
    end

    def creature_type_method
      @result.legendary? ? "legendary_creature_type" : "creature_type"
    end

    def cost_args
      @result.mana_cost.map { |k, v| "#{k}: #{v}" }.join(", ")
    end
  end
end
