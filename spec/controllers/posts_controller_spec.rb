require 'spec_helper'

describe PostsController do
  render_views

  describe "access control for non signed in users" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a post" do
        lambda do
          post :create, :post => @attr
        end.should_not change(Post, :count)
      end

      it "should re render the home page" do
        post :create, :post => @attr
        response.should render_template('pages/home')
      end
    end
    describe "success" do
      before(:each) do
        @attr = {:content => "Valid contents muwwhaha"}
      end

      it "should change the number of posts" do
        lambda do
          post :create, :post => @attr
        end.should change(Post, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create, :post => @attr
        response.should redirect_to(root_path)
      end

      it "should flash a success message" do
        post :create, :post => @attr
        flash[:success].should =~ /post created/i
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
      @post1 = Factory(:post, :user => @user, :content => "murr post content")
    end

    describe "non signed in user" do
      it "should not allow a post to be deleted" do
        lambda do
          delete :destroy, :id => @post1
        end.should_not change(Post, :count)
      end

      it "should redirect_to the signin path" do
        delete :destroy, :id => @post1
        response.should redirect_to(signin_path)
      end
    end

    describe "signed in users" do
      describe "incorrect user" do
        before(:each) do
          test_sign_in(Factory(:user, :email => Factory.next(:email)))
        end

        it "should not change the count of posts" do
          lambda do
            delete :destroy, :id => @post1
          end.should_not change(Post, :count)
        end

        it "should redirect_to root_path" do
          delete :destroy, :id => @post1
          response.should redirect_to root_path
        end
      end

      describe "correct user" do
        before(:each) do
          test_sign_in(@user)
        end
        
        it "should remove the post" do
          lambda do
            delete :destroy, :id => @post1
          end.should change(Post, :count).by(-1)
        end

        it "should display a success message" do
          delete :destroy, :id => @post1
          flash[:success].should =~ /Post blasted! Nice work sheriff/i
        end
      end

      describe "admin user" do
        before(:each) do
          admin = Factory(:user, 
            :email => Factory.next(:email),
            :admin => true)
          test_sign_in(admin)
        end

        it "should delete the post" do
          lambda do
            delete :destroy, :id => @post1
          end.should change(Post, :count).by(-1)
        end
      end
    end
  end
end
