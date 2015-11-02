class Provider < ActiveRecord::Base
  belongs_to :application

  def name
    self.class.name.gsub(/[A-Z]/) { |capital| " #{capital}" }.strip
  end

  def slug
    type.underscore.to_s
  end
end
