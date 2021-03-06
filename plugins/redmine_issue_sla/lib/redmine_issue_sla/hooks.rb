module RedmineIssueSla
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_new_before_save(context)
      save_expiration_date(context[:issue])
    end
    
    def controller_issues_edit_before_save(context)
      save_expiration_date(context[:issue])
    end

    def helper_issues_show_detail_after_setting(context)
      detail = context[:detail]

      case detail.prop_key
      when 'issue_sla'
        value = detail.value; old_value = detail.old_value
        
        if value
          detail.value = l('datetime.distance_in_words.x_hours', :count => value)
        end
        if old_value
          detail.old_value = l('datetime.distance_in_words.x_hours', :count => old_value)
        end
      end

      context[:detail] = detail
    end

    private
      def save_expiration_date(issue, user = User.current)
        return if issue.first_response_date

        previous_values = issue.attributes_before_change
        if user.allowed_to?(:add_issues, issue.project) && (issue.new_record? || issue.priority_id != previous_values['priority_id'])
          sla = issue.priority_issue_sla
            if sla && sla.allowed_delay.present?

              attrs = { :expiration_date => sla.allowed_delay.hours.from_now.round, :issue_sla => sla.allowed_delay }
              issue.assign_attributes attrs, :without_protection => true
              previous_values['expiration_date'] = issue.expiration_date if previous_values
            end
        end

        if user.allowed_to?(:be_project_manager, issue.project) && (issue.new_record? || issue.status_id != previous_values['status_id'])
          attrs = { :first_response_date => Time.now.round }
          issue.assign_attributes attrs, :without_protection => true
          previous_values['first_response_date'] = issue.first_response_date if previous_values
        end
        p ' am okay ===='
      end
    
  end
  
  class ViewHooks < Redmine::Hook::ViewListener
    # i deleted this file from 'issue/show_expiration'
    # render_on :view_issues_show_details_bottom, :partial => "issues/show_expiration"
  end
end
