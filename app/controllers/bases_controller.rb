class BasesController < ApplicationController
  before_action :admin_user
  before_action :set_base, only:[:edit, :destroy, :index, :new, :update]
  
  def index
    @bases =  Base.all
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Create.new(base_params)
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
      falsh[:success] = "拠点の修正をしました。"
      redirect_to bases_url
    else
      render edit
    end
  end
    
  def destroy
    @base.destroy
      flash[:success] = "#{base_name}を削除しました。"
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
