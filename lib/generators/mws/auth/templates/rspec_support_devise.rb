include Devise::TestHelpers

def login_user(group = nil)
  @current_user = Factory(:user)
  User.stub(:find => @current_user)
  if (group)
    ug = Factory(:group, :name => group.to_s.camelcase)
    @current_user.stub!(:groups).and_return([ug])
  end
  sign_in :user, @current_user
end

def should_be_allowed
  controller.should_not_receive(:access_denied)
end

def should_be_forbidden
  controller.should_receive(:access_denied)
end

def should_be_allowed_for(group)
  login_user(group)
  should_be_allowed
end

def should_be_forbidden_for(group)
  login_user(group)
  should_be_forbidden
end
