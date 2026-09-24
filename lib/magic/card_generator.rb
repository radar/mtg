# frozen_string_literal: true

module Magic
  # Renders a CardParser::Result as Ruby source for lib/magic/cards/.
  class CardGenerator
    # A hyphen separates words ("First-Year" -> first_year / FirstYear), as in the
    # hand-written cards and the specs' Card() helper.
    def self.snake_name(name)
      name.downcase.tr("-", " ").gsub(/[^a-z0-9\s]/, "").split.join("_")
    end

    def self.const_name(name)
      name.tr("-", " ").gsub(/[^A-Za-z0-9\s]/, "").split.map { _1[0].upcase + _1[1..] }.join
    end

    def self.generate(result)
      new(result).generate
    end

    def initialize(result)
      @result = result
    end

    BUILDERS = {
      creature: "Creature", instant: "Instant", sorcery: "Sorcery", enchantment: "Enchantment",
      artifact: "Artifact", equipment: "Equipment", aura: "Aura", saga: "Saga"
    }.freeze

    def generate
      case kind
      when :basic_land then basic_land_source
      when :land then land_source
      else builder_source
      end
    end

    private

    # What sort of card this is, or UnsupportedCard for type lines not handled yet.
    def kind
      types = @result.types - ["Kindred"]
      subtypes = @result.subtypes
      return :creature if types.include?("Creature")
      raise CardParser::UnsupportedCard, "unsupported type line: #{types.join(' ')}" if types.size != 1

      case types.first
      when "Land" then land_kind
      when "Enchantment" then subtypes == ["Aura"] ? :aura : subtypes == ["Saga"] ? :saga : plain(:enchantment)
      when "Artifact" then subtypes == ["Equipment"] ? :equipment : plain(:artifact)
      when "Instant" then plain(:instant)
      when "Sorcery" then plain(:sorcery)
      else raise CardParser::UnsupportedCard, "unsupported type: #{types.first}"
      end
    end

    def kindred? = @result.types.include?("Kindred")

    # Card types with no subtypes to worry about (a Kindred card's are creature types).
    def plain(kind)
      raise CardParser::UnsupportedCard, "subtypes not supported for #{kind}: #{@result.subtypes.join(' ')}" if @result.subtypes.any? && !kindred?

      kind
    end

    def land_kind
      raise CardParser::UnsupportedCard, "legendary lands not supported" if @result.legendary?
      return :land if @result.supertypes.empty? && @result.subtypes.empty?
      return :basic_land if @result.supertypes == ["Basic"] && @result.subtypes.size == 1

      raise CardParser::UnsupportedCard, "unsupported land: #{@result.supertypes.join(' ')} #{@result.subtypes.join(' ')}"
    end

    def const
      @const ||= self.class.const_name(@result.name)
    end

    def wrap(source)
      "module Magic\n  module Cards\n#{source.gsub(/^(?=.)/, '    ')}  end\nend\n"
    end

    # Instant("Name") do ... end plus an optional class reopening for nested classes.
    def builder_source
      kind = self.kind
      require_rule(kind)
      check_rule_kinds(kind)
      lines = []
      lines << "cost #{cost_args}" if @result.mana_cost.any?
      lines.concat(type_lines(kind))
      lines.concat(@result.rules.flat_map(&:dsl_lines))
      if kind == :creature
        lines << "power #{@result.power}"
        lines << "toughness #{@result.toughness}"
      end
      base = BUILDERS.fetch(kind)
      source = +"#{const} = #{base}(#{@result.name.inspect}) do\n"
      lines.each { |l| source << "  #{l}\n" }
      source << "end\n"
      sections = class_sections
      source << "\nclass #{const} < #{base}\n#{sections.map { indent(_1) }.join("\n\n")}\nend\n" if sections.any?
      wrap(source)
    end

    def land_source
      sections = class_sections
      body = ["NAME = #{@result.name.inspect}", *sections].join("\n\n")
      wrap("class #{const} < Land\n#{indent(body)}\nend\n")
    end

    def basic_land_source
      subtype = @result.subtypes.first
      wrap("class #{const} < BasicLand\n  type Types::Lands::#{subtype}\nend\n")
    end

    def type_lines(kind)
      return kindred_type_lines(kind) if kindred?

      case kind
      when :creature then creature_type_lines
      when :artifact then @result.legendary? ? ["legendary_artifact"] : []
      else
        raise CardParser::UnsupportedCard, "legendary #{kind} not supported" if @result.legendary?

        []
      end
    end

    # "Kindred Artifact — Shapeshifter" -> type T::Kindred, T::Artifact, T::Creatures["Shapeshifter"]
    def kindred_type_lines(kind)
      raise CardParser::UnsupportedCard, "unsupported Kindred card: #{kind}" unless %i[artifact enchantment instant sorcery].include?(kind)
      raise CardParser::UnsupportedCard, "legendary Kindred cards not supported" if @result.legendary?
      unless (@result.subtypes - Types::Creatures.values).empty?
        raise CardParser::UnsupportedCard, "Kindred subtypes must be creature types: #{@result.subtypes.join(' ')}"
      end

      creature_types = @result.subtypes.map { "T::Creatures[#{_1.inspect}]" }
      ["type #{['T::Kindred', "T::#{kind.to_s.capitalize}", *creature_types].join(', ')}"]
    end

    def creature_type_lines
      method = creature_type_method or raise CardParser::UnsupportedCard, "unsupported creature type line"
      @result.subtypes.empty? ? [] : ["#{method}(#{@result.subtypes.join(' ').inspect})"]
    end

    def creature_type_method
      extras = @result.types - ["Creature"]
      return "legendary_creature_type" if @result.legendary? && extras.empty?
      return if @result.legendary?

      case extras
      when [] then "creature_type"
      when ["Artifact"] then "artifact_creature_type"
      when ["Enchantment"] then "enchantment_creature_type"
      end
    end

    # A rule that only makes sense on some kinds (spell effects on instants/sorceries).
    def check_rule_kinds(kind)
      @result.rules.each do |rule|
        next if rule.kinds.nil? || rule.kinds.include?(kind)

        raise CardParser::UnsupportedCard, "#{rule.class.name.split('::').last} not supported on #{kind}"
      end
    end

    # Kinds whose Oracle text always includes a particular line.
    REQUIRED_RULE = {
      equipment: %w[Equip], aura: %w[Enchant], instant: %w[SpellEffect Modal], sorcery: %w[SpellEffect Modal], saga: %w[Chapter]
    }.freeze

    def require_rule(kind)
      names = REQUIRED_RULE[kind] or return
      return if @result.rules.any? { names.include?(_1.class.name.split("::").last) }

      raise CardParser::ParseError, "#{kind} needs an #{names.join(' or ')} line"
    end

    # Sections for the class body: rule-provided bodies, then nested classes per hook.
    def class_sections
      bodies = @result.rules.filter_map(&:body_source).map(&:chomp)
      hooked = @result.rules.select(&:hook)
      hooks = CardParser::Rule::HOOKS.filter_map { |hook| hook_section(hook, hooked.select { _1.hook == hook }) }
      bodies + hooks.map(&:chomp)
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

    # Abilities and lifecycle triggers are lists; event handlers map event =>
    # ability, or => [abilities] when several handle one event.
    def hook_definition(hook, named)
      return "def #{hook} = [#{named.map(&:last).join(', ')}]\n" unless hook == :event_handlers

      pairs = named.group_by { |rule, _| rule.handled_event }.map do |event, handlers|
        names = handlers.map(&:last)
        "#{event} => #{names.size == 1 ? names.first : "[#{names.join(', ')}]"}"
      end
      "def event_handlers = { #{pairs.join(', ')} }\n"
    end

    def indent(source)
      source.lines.map { |line| line.strip.empty? ? line : "  #{line}" }.join.chomp
    end

    def cost_args
      @result.mana_cost.map { |k, v| "#{k}: #{v}" }.join(", ")
    end
  end
end
