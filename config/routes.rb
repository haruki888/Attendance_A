Rails.application.routes.draw do
  root 'static_pages#top' #rootにするとURL/へアクセスした時にトップページが表示されるようになる
  get '/signup', to: 'users#new'
  
  #ログイン
  get '/login', to: 'sessions#new'        #新しいセッションのページ 
  post '/login', to: 'sessions#create'    #新しいセッションの作成 
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection {post :import} #:idでurlを識別する必要がない場合はcollectionで設定
    member do                 #:idがつくURIを生成する
      get 'edit_basic_info'                  #基本情報
      patch 'update_basic_info'              #基本情報登録
      
      get 'attendances/edit_one_month'       #勤怠編集画面
      patch 'attendances/update_one_month'   #勤怠編集画面登録
      
      get 'show_verify'                     #上長勤怠確認
      
      get 'commuting_employee'    #出勤中社員一覧
    end
      resources :attendances, only: :update do
        member do
          get 'edit_request_change'        #勤怠変更申請モーダル
          patch 'update_request_change'    #勤怠変更申請登録
         
          get 'edit_request_overtime'      #残業申請モーダル
          patch 'update_request_overtime'  #残業申請登録
          
          get 'edit_overtime_approval'     #残業承認
          patch 'update_overtime_approval' #残業承認登録
          
          get 'edit_one_month_approval'    #1ヶ月の勤怠承認
          patch 'update_one_month_approval'#1ヶ月の勤怠承認登録
          
          get 'edit_fix_log'               #勤怠修正ログ (承認済)
         
        end
      end
    end
    resources :bases
end