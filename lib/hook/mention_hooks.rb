module Hook
  class MentionHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_top, :partial => 'issue/form'
    render_on :view_layouts_base_content, :partial => 'wiki/form'
    render_on :view_my_account_preferences, :partial => 'users/mention_preferences'
  end
end
