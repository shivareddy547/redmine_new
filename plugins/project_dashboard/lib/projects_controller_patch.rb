# include DashboardHelper
module ProjectsControllerPatch

  BLOCKS = { 'issuesassignedtome' => :label_assigned_to_me_issues,
             'issuesreportedbyme' => :label_reported_issues,
             'issueswatched' => :label_watched_issues,
             'news' => :label_news_latest,
             'calendar' => :label_calendar,
             'documents' => :label_document_plural,
             'timelog' => :label_spent_time,
             'overduetasks' => :label_overdue_tasks,
             'unmanageabletasks' => :label_unmanageable_tasks
  }.merge(Redmine::Views::MyPage::Block.additional_blocks).freeze

  DEFAULT_LAYOUT = {  'left' => ['issuesassignedtome'],
                      'right' => ['issuesreportedbyme']
  }.freeze

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      # helper :search

      # include SearchHelper
      # Insert overrides here, for example:
      def show
        @project= Project.find(params[:id])
        retrieve_dash_board_query
        sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
        sort_update(@query.sortable_columns)
        @query.sort_criteria = sort_criteria.to_a

        # if @query.valid?
        #   case params[:format]
        #     when 'csv', 'pdf'
        #       @limit = Setting.issues_export_limit.to_i
        #       if params[:columns] == 'all'
        #         @query.column_names = @query.available_inline_columns.map(&:name)
        #       end
        #     when 'atom'
        #       @limit = Setting.feeds_limit.to_i
        #     when 'xml', 'json'
        #       @offset, @limit = api_offset_and_limit
        #       @query.column_names = %w(author)
        #     else
        #       @limit = per_page_option
        #   end
        #
        #   @issue_count = @query.issue_count
        #   end

        # Dashboard.statement(IssueQuery.last.filters)
        @user = User.current
        @project_preference = ProjectUserPreference.project_user_preference(User.current.id,@project.id)
        @blocks = @project_preference[:my_page_layout] || DEFAULT_LAYOUT
        # try to redirect to the requested menu item
        if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
          return
        end

        @users_by_role = @project.users_by_role
        @subprojects = @project.children.visible.all
        @news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").all
        @trackers = @project.rolled_up_trackers

        cond = @project.project_condition(Setting.display_subprojects_issues?)

        @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
        @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count

        if User.current.allowed_to?(:view_time_entries, @project)
          @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
        end

        @chart = params[:chart] || "issues_burndown"
        # @project = Project.find(params[:project_id])
        # retrieve_dash_board_query
        # retrieve_charts_query
        # @query.date_to ||= Date.today
        # @issues = @query.issues

        # p "+++++++++++++++++++++++++++=@query.filters++++++++++++++++++++++"
        # p @query.filters
        # p @query.filters["fixed_version_id"].values.last.first
        # p "++++++++++++++++++++++++++++++++++++="

        if @query.present? && @query.filters.present? && @query.filters["fixed_version_id"].present?
        find_fixed_version_id= @query.filters["fixed_version_id"].values.last.first
        find_version = Version.find(find_fixed_version_id)
        p "+++++++++fixed version id ++++++++++"
        p find_version.id
        start_date = find_version.ir_start_date
        end_date = find_version.ir_end_date
        total_no_of_days = (start_date.to_date..end_date.to_date).to_a.count
        @total_dates= (start_date.to_date..end_date.to_date).to_a
        @idle_issues_count = @project.issues.where("issues.fixed_version_id IN (#{find_version.id})").count
        @idle_issues_total_count = @idle_issues_count
       idle_issues_devide = (@idle_issues_count.to_f/total_no_of_days.to_f)

        @idle_issues_count_array=[]
        @issues_count_array=[]
        (start_date.to_date..end_date.to_date).to_a.each_with_index do |each_day,index|
          if index.to_i ==0
            @idle_issues_count_array << @idle_issues_count
          else
            @idle_issues_count_array << @idle_issues_count -= idle_issues_devide
          end

          # p "issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.tracker_id IN ('1') AND issues.created_on > '#{each_day}'"
          # issues_count = @project.issues.open.where("issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.fixed_version_id IN (#{find_version.id})").count
         # p date_obj = Time.parse(each_day.to_date.to_s)
          closed_issues = @project.issues.where("issues.closed_on <= ? AND issues.fixed_version_id= ?",Time.parse(each_day.to_date.to_s) , find_version.id).count
          # @idle_issues_total_count
          issues_count = (@idle_issues_total_count.to_i-closed_issues.to_i)
          @issues_count_array << issues_count rescue 0

        end

        else
          total_no_of_days= 30
          start_date = (Date.today-total_no_of_days)
          end_date = Date.today
          @total_dates= ((Date.today-30)..Date.today).to_a

          # find_version = Version.where(:project_id=>@project.id).last
          # start_date = find_version.ir_start_date
          # end_date = find_version.ir_end_date
          # total_no_of_days = (find_version.ir_start_date.to_date..find_version.ir_end_date.to_date).to_a.count
          # @total_dates= ((start_date)..end_date).to_a
          # @idle_issues_count = Issue.visible.where("issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.fixed_version_id IN (#{find_version.id}) AND issues.created_on between '#{start_date}' and '#{end_date}'").count
          # idle_issues_devide = @idle_issues_count/total_no_of_days

          @idle_issues_count = @project.issues.where("issues.created_on between '#{start_date}' and '#{end_date}'").count

          @idle_issues_total_count = @idle_issues_count
          idle_issues_devide = (@idle_issues_count.to_f/total_no_of_days.to_f)

          @idle_issues_count_array=[]
          @issues_count_array=[]
          (start_date.to_date..end_date.to_date).to_a.each_with_index do |each_day,index|
            if index.to_i ==0
              @idle_issues_count_array << @idle_issues_count
            else
              @idle_issues_count_array << @idle_issues_count -= idle_issues_devide
            end

            # p "issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.tracker_id IN ('1') AND issues.created_on > '#{each_day}'"
            # issues_count = @project.issues.open.where("issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.fixed_version_id IN (#{find_version.id})").count
            # p date_obj = Time.parse(each_day.to_date.to_s)
            closed_issues = @project.issues.where("issues.created_on between '#{start_date}' and '#{end_date}'").where("issues.closed_on <= ?",Time.parse(each_day.to_date.to_s)).count
            # @idle_issues_total_count
            issues_count = (@idle_issues_total_count.to_i-closed_issues.to_i)
            @issues_count_array << issues_count rescue 0


       end
       end
        # p "++++@query.statement+++++++++++++++++"
        # p @query
        # p @query.statement
        # p "++++++++++++++="
        #
        # @idle_issues_count = Issue.visible.where("issues.status_id IN (SELECT id FROM issue_statuses WHERE is_closed=0) AND issues.fixed_version_id IN (#{find_version.id}) AND issues.created_on between '#{start_date}' and '#{end_date}'").count
        # idle_issues_devide = @idle_issues_count/total_no_of_days








        @data = [
            ['Firefox',   100.0],
            ['IE',       26.8],

            ['Safari',    8.5],
            ['Opera',     6.2],
            ['Others',   0.7]
        ]

        @key = User.current.rss_key

        respond_to do |format|
          format.html
          format.api
        end
      end

      def retrieve_dash_board_query
        @find_dashboard_query = DashboardQuery.where(:project_id=>@project.id,:user_id=>User.current.id)
          # @query=nil
        if @find_dashboard_query.present?
          if api_request? || params[:set_filter]
            @init_filters={ 'status_id' => {:operator => "o", :values => [""]} }
            @find_dashboard_query.last.update_attributes(:filters=> @init_filters)
          end
          @query = @find_dashboard_query.last
        else
           @init_filters={ 'status_id' => {:operator => "o", :values => [""]} }
          @query ||= DashboardQuery.new(:name => "_", :filters => @init_filters)
          @query.user_id=User.current.id
          @query.project_id= @project.id
        end

      end

      # def show
      #   @user = User.current
      #   @blocks = @user.pref[:my_page_layout] || DEFAULT_LAYOUT
      #   # try to redirect to the requested menu item
      #   if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
      #     return
      #       #    end
      #
      #   @users_by_role = @project.users_by_role
      #   @subprojects = @project.children.visible.all
      #   @news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").all
      #   @trackers = @project.rolled_up_t        #rackers
      #
      #   cond = @project.project_condition(Setting.display_subprojects_i        #ssues?)
      #
      #   @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
      #   @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker        #).count
      #
      #   if User.current.allowed_to?(:view_time_entries, @project)
      #     @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
      #   end
      #   @data = [
      #       ['Firefox',   100.0],
      #       ['IE',              # 26.8],
      #
      #       ['Safari',    8.5],
      #       ['Opera',     6.2],
      #       ['Others',   0.7]
      #     #      ]
      #
      #   @key = User.current.        #rss_key
      #
      #   respond_to do |format|
      #     format.html
      #     format.api
      #   end
      #
      #   end
      #   end

    end

      #alias_method_chain :show, :plugin # This tells Redmine to allow me to extend show by letting me call it via "show_without_plugin" above.
      # I can outright override it by just calling it "def show", at which case the original controller's method will be overridden instead of extended.
  end
  module InstanceMethods
    # Here, I include helper like this (I've noticed how the other controllers do it)
    # helper :queries
    include ApplicationHelper

    def index_with_filters
      # ...
      # do stuff
      # ...
    end
  end # module
  end


