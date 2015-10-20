module EmployeeInfo
  module Patches
    module MemberPatch
      def self.included(base)
        #base.extend(ClassMethods)
        # base.send(:include, InstanceMethods)
        base.class_eval do
          # validate :validate_billable
          validates_uniqueness_of :billable, :scope => [:user_id], :if => :billable

          def validate_billable
            if !self.billable.present?
               errors.add(:Billable, "can not be blank for #{self.user.firstname.present? ? self.user.firstname : "" }")
            end
          end

          def self.capacity(member)
            total_capacity =   Member.where(:user_id=>member.user_id).map(&:capacity).sum
            return total_capacity*100
          end

          def self.available_capacity(member)
            total_capacity =  Member.where(:user_id=>member.user_id).map(&:capacity).sum
            available_capacity = (1-total_capacity)*100
            return available_capacity
          end
          def self.current_project_capacity(member)
            total_capacity =  Member.where(:user_id=>member.user_id,:project_id=>member.project_id).map(&:capacity).sum
            return total_capacity*100
          end

          def self.other_capacity(member)
            current_capacity =  Member.where(:user_id=>member.user_id,:project_id=>member.project_id).map(&:capacity).sum
            total_capacity =  Member.where(:user_id=>member.user_id).map(&:capacity).sum
            other_capacity = total_capacity.to_f - current_capacity.to_f
            return other_capacity*100
          end
          def self.user_available_capacity(user)
            total_capacity =  Member.where(:user_id=>user.id).map(&:capacity).sum
            available_capacity = (1-total_capacity)*100
            return available_capacity
          end


       end


      end

    end
  end
end



