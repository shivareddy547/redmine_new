module MembersControllerPatch
  def self.included(base)
    base.class_eval do
      # Insert overrides here, for example:
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