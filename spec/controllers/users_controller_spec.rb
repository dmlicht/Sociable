require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should show the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

  describe "GET 'new'" do
    it "should return http success" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = {
          :name => "",
          :email => "",
          :password => "",
          :password_confirmation => ""
        }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do
      before(:each) do
        @attr = {
          :name => "David okayname",
          :email => "david@good.email.com",
          :password => "validpass",
          :password_confirmation => "validpass"
        }
      end

      it "should add a new user to the database" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should flash a welcome message to the user" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to RideSociable/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit")
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "invalid credential" do
      before(:each) do
        @attr = { :name => "", :email => "" }
      end

      it "should re-render the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit")
      end

      it "should not update the users data" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should_not == @attr[:name]
        @user.email.should_not == @attr[:email]
      end

    end

    describe "valid credentials" do
      before(:each) do
        @attr = { :name => "Working Name", :email => "working@email.com" }
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should update the user data" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should flash a success message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/i
      end
    end
  end

  describe "authentification for edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "if not logged in" do
      it "should deny access to the edit page" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to the 'update'" do
        put :update, :id => @user, :user => {}
      end
    end

    describe "if logged in" do
      before(:each) do
        wrong_user = Factory(:user, :email => "wrong@user.com")
        test_sign_in(wrong_user)
      end

      it "should require matching users for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for update" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "GET 'index'" do
    describe "non signed in users" do
      it "should deny access and redirect to sign in" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice] =~ /sign in/i
      end
    end

    describe "signed in users" do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
        second = Factory(:user, :email => "womp@womp.com")
        third = Factory(:user, :email => "womp@wompwomp.net")
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate results" do
        get :index
        response.should have_selector("nav.pagination")
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
      @user2 = Factory(:user, :email => Factory.next(:email))
    end

    describe "as non logged in user" do
      it "should redirect to log in path" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as non admin user" do
      it "should protect the user" do
        test_sign_in(@user2)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end
