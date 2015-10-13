module EmployeeInfo
  module Patches
    module MemberPatch
      def self.included(base)
        #base.extend(ClassMethods)
        #base.send(:include, InstanceMethods)
        base.class_eval do
          validate :validate_billable
          validates_uniqueness_of :billable, :scope => [:user_id], :if => :billable


          def validate_billable

            # find_billable_role = Role.find_by_name("Billable")
            # find_non_billable_role = Role.find_by_name("NonBillable")
            # if self.member_roles.present? && (!self.member_roles.map(&:role_id).include?(find_billable_role.id) && !self.member_roles.map(&:role_id).include?(find_non_billable_role.id))
            #
            #   # errors.add_on_empty :role if member_roles.empty? && roles.empty?
            # end

            if self.billable.nil?
               errors.add(:Billable, "can not be blank for #{self.user.firstname}")
            end

          end

        end
      end
    end
  end
end



