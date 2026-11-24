module Patch
  module IssueQueryPatch
    def self.included(base)
      base.class_eval do
        alias_method :initialize_available_filters_without_mentions, :initialize_available_filters
        alias_method :initialize_available_filters, :initialize_available_filters_with_mentions
      end
    end

    def initialize_available_filters_with_mentions
      initialize_available_filters_without_mentions

      mention_values = lambda do
        principals = []
        if project
          principals += project.principals.visible.to_a
        else
          principals += Principal.visible.active.to_a
        end
        principals.uniq!
        principals.sort!
        users_vals = principals.select { |p| p.is_a?(User) }.map { |u| [u.name, u.id.to_s] }
        groups_vals = principals.select { |p| p.is_a?(Group) }.map { |g| [g.name, g.id.to_s] }

        options = [["<< #{l(:label_me)} >>", "me"]]
        options += users_vals
        options += groups_vals if groups_vals.any?
        options
      end

      add_available_filter(
        "mentioned_user_id",
        type: :list_optional,
        values: mention_values,
        name: l(:label_mentioned_user, default: "Mentioned user")
      )
    end

    def sql_for_mentioned_user_id_field(field, operator, values)
      selected_values = values.map { |v| (v == "me") ? User.current.id.to_s : v }

      settings = Setting.plugin_flux_mentions || {}
      symbol = settings['symbol'].presence || '@'
      escaped_sym = Regexp.escape(symbol)

      # Gather logins and group names for selected ids
      targets = []
      selected_values.each do |val|
        if (principal = Principal.find_by(id: val))
          if principal.is_a?(User)
            targets << "#{symbol}#{principal.login}"
          elsif principal.is_a?(Group)
            targets << "#{symbol}#{principal.name}"
            targets << "#{symbol}#{principal.lastname}" if principal.lastname.present?
          end
        end
      end

      return "1=0" if (operator == '=' && targets.empty?)
      return "1=1" if (operator == '!' && targets.empty?)

      # Build LIKE or NOT LIKE clauses across issues.description and journals.notes
      neg = (operator == '!' ? 'NOT' : '')

      # Description conditions
      desc_clauses = targets.map do |token|
        sanitize_sql_for_conditions(["LOWER(#{Issue.table_name}.description) LIKE LOWER(?)", "%#{token}%"])
      end.join(' OR ')

      # Notes subquery condition
      notes_clauses = targets.map do |token|
        sanitize_sql_for_conditions(["LOWER(#{Journal.table_name}.notes) LIKE LOWER(?)", "%#{token}%"])
      end.join(' OR ')

      notes_subquery = "SELECT 1 FROM #{Journal.table_name} " \
                       "WHERE #{Journal.table_name}.journalized_type='Issue' " \
                       "AND #{Journal.table_name}.journalized_id=#{Issue.table_name}.id " \
                       "AND (#{notes_clauses}) " \
                       "AND (#{Journal.visible_notes_condition(User.current, skip_pre_condition: true)})"

      combined = "(#{desc_clauses}) OR EXISTS (#{notes_subquery})"

      if operator == '!'
        "NOT (#{combined})"
      else
        "(#{combined})"
      end
    end
  end
end
