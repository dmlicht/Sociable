class PairsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => [:update, :destroy]
  before_filter :pair_accepted, :only => [:update]
  before_filter :requestee, :only => [:accept]

  def create
    @wing_to_add = User.find(params[:pair][:wing])
    current_user.request_wing!(@wing_to_add)
    respond_to do |format|
      format.html {
        flash[:success] = "requested wing"
        redirect_to root_path
      }
      format.js
    end
  end

  def update
    @pair.update_attributes!(params[:pair])
    flash[:success] = "Pair updated. Wink."
  end

  def accept
    @requester = @pair.user
    current_user.accept_wing!(@requester)
    flash[:success] = "Wing accepted!"
    redirect_to root_path
  end

  def destroy
    @pair.destroy
    respond_to do |format|
      format.html {
        flash[:success] = "pair deleted"
        redirect_to root_path
      }
      format.js
    end
  end

  private
    def authorized_user
      @pair = Pair.find(params[:id])
      redirect_to root_path unless current_user.admin? or current_user?(@pair.wing) or current_user?(@pair.user)
    end

    def pair_accepted
      @pair = Pair.find(params[:id])
      redirect_to root_path unless @pair.accepted?
    end

    def requestee
      @pair = Pair.find_by_user_id(params[:pair][:user_id])
      redirect_to root_path unless current_user?(@pair.wing)
    end
end
