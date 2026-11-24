module Patch
  module ApplicationHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unless method_defined?(:parse_redmine_links_without_custom_mentions)
          alias_method :parse_redmine_links_without_custom_mentions, :parse_redmine_links
          alias_method :parse_redmine_links, :parse_redmine_links_with_custom_mentions
        end
      end
    end

    module InstanceMethods
      def parse_redmine_links_with_custom_mentions(text, default_project, obj, attr, only_path, options)
        settings = Setting.plugin_flux_mentions || {}
        symbol = settings['symbol'].presence || '@'
        group_enabled = settings['enable_group_mentions'] == '1' || settings['enable_group_mentions'] == true
        rich_chips = settings['enable_rich_chips'] == '1' || settings['enable_rich_chips'] == true

        all_symbols = ['@', '$', ':', '~', '!', '%']
        all_symbols = [symbol] | all_symbols

        all_symbols.each do |sym|
          mention_regex = /#{Regexp.escape(sym)}(?<identifier>[\w.\-]+)/

          text.gsub!(mention_regex) do |_|
            identifier = Regexp.last_match[:identifier]

            # Try matching user first
            user = User.visible.find_by("LOWER(login) = :s AND type = 'User'", s: identifier.downcase)
            if user
              name_display = "#{user.firstname} #{user.lastname}".strip
              name_display = user.login if name_display.blank?
              chip_style = rich_chips ? "display:inline-flex;align-items:center;background:#eef2ff;color:#3730a3;border:1px solid #c7d2fe;padding:1px 6px;border-radius:12px;font-weight:500;text-decoration:none;" : ""
              link_to("#{sym}#{name_display}", { controller: 'users', action: 'show', id: user.id, only_path: only_path }, class: 'user-mention', style: chip_style)
            elsif group_enabled && (group = Group.find_by("LOWER(lastname) = :s", s: identifier.downcase))
              group_style = rich_chips ? "display:inline-flex;align-items:center;background:#fef3c7;color:#92400e;border:1px solid #fde68a;padding:1px 6px;border-radius:12px;font-weight:500;text-decoration:none;" : ""
              content_tag(:span, "#{sym}#{group.name}", class: 'group-mention', style: group_style)
            else
              "#{sym}#{identifier}"
            end
          end
        end

        text
      end
    end
  end
end
