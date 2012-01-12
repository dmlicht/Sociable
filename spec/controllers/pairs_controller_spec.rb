require 'spec_helper'

describe PairsController do

  describe "POST 'create'" do
    describe "non logged in user" do
      it "should deny access" do
        post :create
        response.should redirect_to signin_path
      end

      it "should not change the number of pairs" do
        lambda do
          post :create
        end.should_not change(Pair, :count)
      end
    end

    describe "logged in user" do
      before(:each) do
        @user = Factory(:user)
        @wing = Factory(:user, :email => Factory.next(:email))
        @attr = {:wing => @wing}
        test_sign_in(@user)
      end

      it "adds a pair" do
        lambda do
          post 'create', :pair => @attr
        end.should change(Pair, :count).by(1)
      end

      it "should redirect to root path" do
        post :create, :pair => @attr
        response.should redirect_to(root_path)
      end

      it "should flash a success message" do
        post :create, :pair => @attr
        flash[:success] =~ /awesome/i
      end

      it "should create a pair using ajax" do
        lambda do
          xhr :post, :create, :pair => @attr
          response.should be_success
        end.should change(Pair, :count).by(1)
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      @requester = Factory(:user, :email => Factory.next(:email))
      @pair = Factory(:pair, :user => @requester, :wing => @user, :interested_in => "party time")
      @attr = {:interested_in => "hangin."}
    end

    describe "non logged in user" do
      it "should block access and redirect to login" do
        put :update, :id => @pair, :pair => @attr
        response.should redirect_to(signin_path)
      end

      it "should not update the information" do
        put :update, :id => @pair, :pair => @attr
        @pair.reload
        @pair.interested_in.should_not == @attr[:interested_in]
      end
    end

    describe "wrong user" do
      before(:each) do
        other_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(other_user)
      end

      it "should block access and redirect to root path" do
        put :update, :id => @pair, :pair => @attr
        response.should redirect_to(root_path)
      end

      it "should not update the information" do
        put :update, :id => @pair, :pair => @attr
        @pair.reload
        @pair.interested_in.should_not == @attr[:interested_in]
      end
    end

    describe "admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@gmail.com", :admin => true)
        test_sign_in(admin)
        @user.accept_wing!(@requester)
      end

      it "should update the info" do
        put :update, :id => @pair, :pair => @attr
        @pair.reload
        @pair.interested_in.should == @attr[:interested_in]
      end

      it "should flash a success message" do
        put :update, :id => @pair, :pair => @attr
        flash[:success].should =~ /updated/i
      end
    end

    describe "members of the pair" do
      before(:each) do
        test_sign_in(@user)
      end

      describe "before pair is confirmed" do
        it "should not update the information" do
          put :update, :id => @pair, :pair => @attr
          @pair.reload
          @pair.interested_in.should_not == @attr[:interested_in]
        end

        it "should redirect home" do
          put :update, :id => @pair, :pair => @attr
          response.should redirect_to(root_path)
        end
      end

      describe "after the pair is confirmed" do
        before(:each) do
          @user.accept_wing!(@requester)
        end

        it "should update the information" do
          put :update, :id => @pair, :pair => @attr
          @pair.reload
          @pair.interested_in.should == @attr[:interested_in]
        end

        it "should flash a success message" do
          put :update, :id => @pair, :pair => @attr
          flash[:success].should =~ /updated/
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
      @requester = Factory(:user, :email => Factory.next(:email))
      @pair = Factory(:pair, :user => @requester, :wing => @user, :accepted => true)
    end

    describe "non signed-in user" do
      it "should redirect" do
        delete :destroy, :id => @pair
        response.should redirect_to(signin_path)
      end

      it "should not change number of pairs" do
        lambda do
          delete :destroy, :id => @pair
        end.should_not change(Pair, :count)
      end
    end

    describe "incorrect user" do
      before(:each) do
        incorrect_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(incorrect_user)
      end

      it "should redirect to root path" do
        delete :destroy, :id => @pair
        response.should redirect_to(root_path)
      end

      it "should not change the number of pairs" do
        lambda do
          delete :destroy, :id => @pair
        end.should_not change(Pair, :count)
      end
    end

    describe "admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@gmail.com", :admin => true)
        test_sign_in(admin)
      end

      it "should delete the pair" do
        lambda do
          delete :destroy, :id => @pair
        end.should change(Pair, :count).by(-1)
      end

      it "should flash an successfully deleted message" do
        delete :destroy, :id => @pair
        flash[:success] =~ /pair elimated/i
      end
    end

    describe "user involved in pair" do
      before(:each) do
        test_sign_in(@user)
      end

      it "should delete the pair" do
        lambda do
          delete :destroy, :id => @pair
        end.should change(Pair, :count).by(-1)
      end

      it "should flash an successfully deleted message" do
        delete :destroy, :id => @pair
        flash[:success] =~ /no longer date pals/i
      end

      it "should redirect to root path" do
        delete :destroy, :id => @pair
        response.should redirect_to(root_path)
      end

      it "should destroy a relationship using ajax" do
        lambda do
          xhr :delete, :destroy, :id => @pair
          response.should be_success
        end.should change(Pair, :count).by(-1)
      end
    end
  end
end
