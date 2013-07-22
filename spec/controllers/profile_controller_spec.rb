require 'spec_helper'

describe ProfileController do

  context "when not logged in" do
    it "all actions should return 401" do
      actions = [:edit, :update]

      actions.each do |action|
        get action, :id => 1
        response.code.should == "401"
      end
    end
  end

  context "when logged in" do
    let!(:user_new_attrs) do
      { :user => { :email => 'asdf@asdf.ru' } }
    end

    before do
      @user = create :user
      login_user
    end

    describe "#edit" do
      it "should return success" do
        get :edit
        response.should be_success
      end
    end


    describe "#update" do
      context "with valid params" do
        it "should update profile" do
          post :update, user_new_attrs
          controller.current_user.email.should == user_new_attrs[:user][:email]
        end
      end

      context "with invalid params" do
        it "render " do
          post :update, :user => { :email => 'asdf' }
          response.should render_template('edit')
        end
      end
    end
  end

end