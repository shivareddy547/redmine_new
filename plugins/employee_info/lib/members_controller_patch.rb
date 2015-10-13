module MembersControllerPatch
  def self.included(base)
    base.class_eval do
      # Insert overrides here, for example:

      def create
        members = []
        if params[:membership]
          if params[:membership][:user_ids]
            attrs = params[:membership].dup
            user_ids = attrs.delete(:user_ids)
            user_ids.each do |user_id|
              members << Member.new(:role_ids => params[:membership][:role_ids], :user_id => user_id,:billable=> params[:billable].present? ? params[:billable]=="Billable" ? "true" : "false" : "")
            end
          else
            members << Member.new(:role_ids => params[:membership][:role_ids], :user_id => params[:membership][:user_id],:billable=> params[:billable].present? ? params[:billable]=="Billable" ? "true" : "false" : "")
          end
          @project.members << members
        end

        respond_to do |format|
          format.html { redirect_to_settings_in_projects }
          format.js { @members = members }
          format.api {
            @member = members.first
            if @member.valid?
              render :action => 'show', :status => :created, :location => membership_url(@member)
            else
              render_validation_errors(@member)
            end
          }
        end
      end


      def update
         if params[:membership]
          @member.role_ids = params[:membership][:role_ids]
          @member.billable=params[:billable]
        end
        saved = @member.save
        respond_to do |format|
          format.html { redirect_to_settings_in_projects }
          format.js
          format.api {
            if saved
              render_api_ok
            else
              render_validation_errors(@member)
            end
          }
        end
      end
  end
  end
end