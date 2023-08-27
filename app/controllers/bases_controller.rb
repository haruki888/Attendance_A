class BasesController < ApplicationController
  before_action :admin_user
  before_action :set_base, only: %i[index edit update destroy]
  
  def index
    @user = User.new
    @bases = Base.all
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点を追加登録しました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点を追加出来ませんでした。"
      render :index
    end
  end
  
  def edit
  end
  
  def update
    if @base.update.attributes(base_params)
      flash[:success] = "拠点の修正をしました。"
      redirect_to bases_url
    else
      render edit
    end
  end
    
  def destroy
    if @base.destroy
      flash[:success] = "#{@base_name}を削除しました。"
    else
      flash.now[:danger] = "#{@base_name}の削除が出来ませんでした。"
    end  
      redirect_to base_url
  end
  
  private
  
  def base_params
    params.require(:base).permit(:base_number, :base_name, :base_type)
  end
  
  def set_base
    @base = Base.find(params[:id])
  end
end