class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception #CSRF対策(クロスサイトリクエストフォージェリ)
  include SessionsHelper                #サイトに攻撃用のコードを仕込むことで、アクセスした
                                        #ユーザーに対して意図しない操作を行わせる攻撃のこと
                                        #<%= csrf_meta_tags %> applicaiton.html.erb.rbとセット  
end
