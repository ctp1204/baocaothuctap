class Admin::UsersController < Admin::BaseController
  layout "admin"
  authorize_resource
  before_action :load_user, only: %i(update destroy)
  before_action :set_admin_or_user, only: :update

  def index
    @search = User.ransack params[:q]
    @users = @search.result.sort_by_created_at.paginate page: params[:page],
      per_page: Settings.controllers.user.index_page_admin
    respond_to do |format|
      format.html
      format.csv {send_data @users.to_csv}
      format.xls {send_data @users.to_csv(col_sep: "\t")}
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      redirect_to admin_users_path
      flash[:success] = t "controller.user.create_user"
    else
      render :new
    end
  end

  def update
    if @user.save
      respond_to do |format|
        format.html{ redirect_to request.referrer }
        format.js
      end
    else
      flash[:danger] = t "controller.user.nofound"
      redirect_to request.referrer
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controller.user.delete_user"
      redirect_to admin_users_path
    else
      flash[:danger] = t "controller.user.delete_faild"
      redirect_to admin_root_path
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :phone,
      :address, :password, :password_confirmation, :role, :picture
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "controller.user.find_user_error"
    redirect_to admin_root_path
  end

  def set_admin_or_user
    @user.role = @user.admin? ? :user : :admin
  end
end
