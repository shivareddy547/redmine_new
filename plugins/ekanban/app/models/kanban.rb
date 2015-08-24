class Kanban < ActiveRecord::Base
  unloadable

  belongs_to  :project
  belongs_to  :tracker
  belongs_to  :creater, :foreign_key => :created_by, :class_name => :User
  has_many  :kanban_pane, :order => "position ASC"
  validates_presence_of  :project_id, :tracker_id

  before_destroy :delete_all_members

  #scope :by_project_tracker, lambda{ |project,tracker| {:conditions => ["#{Kanban.table_name}.project_id = #{project} and #{Kanban.table_name}.tracker_id = #{tracker_id}"]}}
  scope :by_project, lambda {|project|
  	project_id = project.nil? ? Project.current : project.is_a?(Project) ? project.id : project.to_i
  	where(:project_id => project_id)
  }
  scope :by_tracker, lambda {|tracker| where(:tracker_id => tracker)}
  scope :valid, lambda {where(:is_valid => true)}

  def self.to_id(kanban)
    kanban_id = kanban.nil? ? nil : kanban.is_a?(Kanban) ? kanban.id : kanban.to_i
  end

  def self.to_kanban(kanban)
    kanban = kanban.nil? ? nil : kanban.is_a?(kanban) ? kanban : kanban.find(kanban)
  end
end


