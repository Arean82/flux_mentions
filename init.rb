require_relative 'lib/hook/mention_hooks'
require_relative 'lib/patch/issue_controller_patch'
require_relative 'lib/patch/wiki_controller_patch'
require_relative 'lib/patch/issue_creation_patch'
require_relative 'lib/patch/application_helper_patch'

Redmine::Plugin.register :flux_mentions do
  name 'Redmineflux Mentions plugin'
  author 'Arean Narrayan'
  description 'Facilitates user mentions (@username) in Notes, Descriptions, and Wiki content with autocomplete and email alerts.'
  version '6.1.0'
  url 'https://github.com/Arean82/flux_mentions'
  author_url 'https://github.com/Arean82/'
  requires_redmine version_or_higher: '5.0.0'
  settings default: { 'symbol' => '@' }, partial: 'setting/symbol'
end

Rails.configuration.to_prepare do
  Journal.include(Patch::IssueControllerPatch) unless Journal.included_modules.include?(Patch::IssueControllerPatch)
  Issue.include(Patch::IssueCreationPatch) unless Issue.included_modules.include?(Patch::IssueCreationPatch)
  WikiController.include(Patch::WikiControllerPatch) unless WikiController.included_modules.include?(Patch::WikiControllerPatch)
  ApplicationHelper.include(Patch::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include?(Patch::ApplicationHelperPatch)
end
