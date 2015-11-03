module EmployeeInfo
  module Patches
    module UserPatch
      def self.included(base)
        #base.extend(ClassMethods)

        #base.send(:include, InstanceMethods)

        base.class_eval do
        has_one :user_official_info
        # def self.capacity(user)
        #   total_capacity =   Member.where(:user_id=>user.id).map(&:capacity).sum
        #   return total_capacity*100
        # end
        def self.capacity(user)
          total_capacity =  Member.where(:user_id=>user.id).map(&:capacity).sum
          available_capacity = (1-total_capacity)*100
          return available_capacity
        end

        end
      end



    end
  end
end



