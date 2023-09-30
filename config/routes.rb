Rails.application.routes.draw do
  root 'static_pages#top'                       #rootにするとURL/へアクセスした時にトップページが表示されるようになる
  get '/signup', to: 'users#new'
  
  #ログイン
  get '/login', to: 'sessions#new'              #新しいセッションのページ 
  post '/login', to: 'sessions#create'          #新しいセッションの作成 
  delete '/logout', to: 'sessions#destroy'

  resources :bases

  resources :users do
    collection { post :import }                 #:idでurlを識別する必要がない場合はcollectionで設定
    member do                                   #:idがつくURIを生成する
      get 'search', to: 'users#search' 
      get 'edit_basic_info'                     #基本情報編集
      patch 'update_basic_info'                 #基本情報更新

      get 'attendances/edit_one_month'          #勤怠編集画面
      patch 'attendances/update_one_month'      #勤怠編集画面登録

      get 'attendances/edit_one_month_apply'    #1ヶ月勤怠申請
      patch 'attendances/update_one_month_apply'#1ヶ月勤怠申請

      get 'show_verify'                         #上長勤怠確認
      
      get 'commuting_employee'                  #出勤中社員一覧
      
      get :export, defaults: { format: 'csv' }
    end
    resources :attendances, only: :update do
      member do
        get 'edit_request_change'               #勤怠変更申請モーダル
        patch 'update_request_change'           #勤怠変更申請承認
        
        get 'edit_request_overtime'             #残業申請モーダル
        patch 'update_request_overtime'         #残業申請登録
        
        get 'edit_overtime_approval'            #残業申請通知モーダル
        patch 'update_overtime_approval'        #残業承認登録
        
        get 'edit_one_month_approval'           #1ヶ月勤怠申請通知モーダル
        patch 'update_one_month_approval'       #1ヶ月勤怠承認
        
        get 'edit_fix_log'                      #勤怠修正ログ (承認済)
      end
    end
  end
end