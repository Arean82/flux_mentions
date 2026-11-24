require_relative 'lib/hook/mention_hooks'
require_relative 'lib/patch/issue_controller_patch'
require_relative 'lib/patch/wiki_controller_patch'
require_relative 'lib/patch/issue_creation_patch'
require_relative 'lib/patch/application_helper_patch'
require_relative 'lib/patch/issue_query_patch'

Redmine::Plugin.register :flux_mentions do
  name 'Redmineflux Mentions plugin'
  author 'Arean Narrayan'
  description 'User & group mentions (@user, @group) in Notes, Descriptions, and Wiki content with autocomplete, email alerts, visual badges, and query filters.'
  version '6.5.0'
  url 'https://github.com/Arean82/flux_mentions'
  author_url 'https://github.com/Arean82/'
  requires_redmine version_or_higher: '5.0.0'
  settings default: {
    'symbol' => '@',
    'enable_group_mentions' => '1',
    'enable_rich_chips' => '1',
    'send_emails' => '1'
  }, partial: 'setting/symbol'

  # Add direct top menu shortcut for logged in users
  menu :top_menu, :my_mentions, { controller: 'my_mentions', action: 'index' },
       caption: :label_my_mentions,
       if: Proc.new { User.current.logged? },
       after: :my_page
end

Rails.configuration.to_prepare do
  Journal.include(Patch::IssueControllerPatch) unless Journal.included_modules.include?(Patch::IssueControllerPatch)
  Issue.include(Patch::IssueCreationPatch) unless Issue.included_modules.include?(Patch::IssueCreationPatch)
  WikiController.include(Patch::WikiControllerPatch) unless WikiController.included_modules.include?(Patch::WikiControllerPatch)
  ApplicationHelper.include(Patch::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include?(Patch::ApplicationHelperPatch)
  IssueQuery.include(Patch::IssueQueryPatch) unless IssueQuery.included_modules.include?(Patch::IssueQueryPatch)
end
