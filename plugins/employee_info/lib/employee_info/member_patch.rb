module EmployeeInfo
  module Patches
    module MemberPatch
      def self.included(base)
        #base.extend(ClassMethods)
        #base.send(:include, InstanceMethods)
        base.class_eval do
          validates_uniqueness_of :billable, :scope => [:user_id], :if => :billable

        end
      end
    end
  end
end



