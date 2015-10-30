
class Sync < ActiveRecord::Base



def self.sync_sql

hrms_sync_details={"adapter"=>ActiveRecord::Base.configurations['hrms_user_sync']['adapter_sync'], "database"=>ActiveRecord::Base.configurations['hrms_user_sync']['database_sync'], "host"=>ActiveRecord::Base.configurations['hrms_user_sync']['host_sync'], "port"=>ActiveRecord::Base.configurations['hrms_user_sync']['port_sync'], "username"=>ActiveRecord::Base.configurations['hrms_user_sync']['username_sync'], "password"=>ActiveRecord::Base.configurations['hrms_user_sync']['password_sync'], "encoding"=>ActiveRecord::Base.configurations['hrms_user_sync']['encoding_sync']}

inia_database_details = {"adapter"=>ActiveRecord::Base.configurations['development']['adapter'], "database"=>ActiveRecord::Base.configurations['development']['database'], "host"=>ActiveRecord::Base.configurations['development']['host'], "port"=>ActiveRecord::Base.configurations['development']['port'], "username"=>ActiveRecord::Base.configurations['development']['username'], "password"=>ActiveRecord::Base.configurations['development']['password'], "encoding"=>ActiveRecord::Base.configurations['development']['encoding']}

# AppSyncInfo.establish_connection(inia_database_details)
        rec = AppSyncInfo.find_or_initialize_by_name('hrms')
        rec.in_progress = true
        if !rec.last_sync.present?
          rec.last_sync=Time.now
          @sync_time = (Time.now - 1.minute)
        else
          @sync_time = (rec.last_sync-1.minute)
        end
        rec.save
    # hrms_connection =  ActiveRecord::Base.establish_connection(:hrms_sync_details)
    hrms =  ActiveRecord::Base.establish_connection(hrms_sync_details).connection
    @user_info = hrms.execute("SELECT a.first_name, a.last_name, b.login_id,c.work_email, c.employee_no FROM hrms.employee a, hrms.user b, hrms.official_info c where b.id=a.user_id and a.id=c.employee_id and a.modified_date >= '#{@sync_time}'")
    hrms.disconnect!
    inia =  ActiveRecord::Base.establish_connection(:production).connection
    @user_info.each(:as => :hash) do |user|

     find_user = "select * from users where users.login='#{user['login_id']}'"
      find_user_res =  inia.execute(find_user)
      if find_user_res.count == 0

        user_insert_query = "INSERT into users(login,firstname,lastname,mail,auth_source_id,created_on,status,type,updated_on)
       VALUES ('#{user['login_id']}','#{user['first_name']}','#{user['last_name']}','#{user['work_email']}',1, NOW(),1,'User',NOW())"
        save_user = inia.insert_sql(user_insert_query)
        user_info_query = "INSERT into user_official_infos (user_id, employee_id) values ('#{save_user.to_i}',#{user['employee_no']})"
        save_employee = inia.insert_sql(user_info_query)
      else
        user_update_query = "UPDATE users SET login='#{user['login_id']}',firstname='#{user['first_name']}',lastname='#{user['last_name']}'
          ,mail='#{user['work_email']}',auth_source_id=1,updated_on=NOW() where login='#{user['login_id']}'"
          update_user = inia.execute(user_update_query)

        find_user_res.each(:as => :hash) do |row|
          update_user_official_info = "UPDATE user_official_infos SET employee_id=#{user['employee_no']} where user_id=#{row["id"]}"
          update_employee = inia.execute(update_user_official_info)
        end
      end
      rec.update_attributes(:last_sync=>Time.now)
    end
  end


# user_insert = "INSERT into users(login,firstname,lastname,mail,auth_source_id,created_on,status,type,updated_on) VALUES ('rrrr547','rrrr','ssss','rrrr@gmail.com',1, NOW(),1,'User',NOW())"


  # final_sql = "INSERT into users(login,firstname,lastname,mail,language,auth_source_id,created_on,hashed_password,status,last_login_on,type,identity_url,mail_notification,salt,must_change_passwd,passwd_changed_on,lastmodified) VALUES ('rrrr547,'rrrr','ssss','rrrr@gmail.com','en',1, NOW(),'',1,NULL,'User', NULL,'',NULL,false,NULL,NOW())"

end
