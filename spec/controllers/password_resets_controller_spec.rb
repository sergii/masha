require 'spec_helper'

describe PasswordResetsController do
  before { ActionMailer::Base.deliveries = [] }
  let(:user) { create :user, { :password => 123, :email => 'ahah@rere.ru' }}

  describe "#new" do
    it "should return success" do
      get :new
      response.should be_success
    end
  end

  describe "#create" do
  	context "with valid params" do
	    it "should send reset password email" do
	      post :create, :email_form => { :email => user.email}
        response.should redirect_to new_session_path
        ActionMailer::Base.deliveries.last.to.first.should == user.email
	    end
  	end

    context "with invalid params" do
      it "should not send reset password email" do
        post :create, :email_form => { :email => 'sdfdsf'}
        response.should render_template('password_resets/new')
        ActionMailer::Base.deliveries.count.should == 0
      end
    end
  end

  describe "#edit" do
    context "with valid params" do
      it "should allow access to set password" do
        user = create :user, {:reset_password_token => 'dfsdf'}
        get :edit, :id => user.reset_password_token
        response.should be_success
      end
    end

    context "with invalid params" do
      it "should not allow access to set password" do
        user = create :user, {:reset_password_token => 'dfsdf'}
        get :edit, :id => '32'
        response.should_not be_success
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      it "should change password" do
        user = create :user, {:reset_password_token => 'dfsdf'}
        old_password = user.crypted_password
        post :update, :id => '32', :token => user.reset_password_token, :password_change_form => {:password => '1234', :password_confirmation => '1234'}
        user.reload
        user.crypted_password.should_not == old_password
        response.should_not be_success
      end
    end

    context "with invalid params" do
      it "should not change password" do
        user = create :user, {:reset_password_token => 'dfsdf'}
        old_password = user.crypted_password
        post :update, :id => '32', :token => user.reset_password_token, :password_change_form => {:password => '1234', :password_confirmation => '124'}
        user.reload
        user.crypted_password.should == old_password
        response.should render_template('password_resets/edit')
      end
    end
  end
end