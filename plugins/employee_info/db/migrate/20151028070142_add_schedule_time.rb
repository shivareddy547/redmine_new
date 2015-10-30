class AddScheduleTime < ActiveRecord::Migration
  def change
    add_column :user_official_infos,:user_sync_schedule_time, :datetime
  end
end
