class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # スコープ内でユーザーがアクセスできるリソースの範囲を定義
      # 例: 管理者ユーザーは全てのユーザーを見ることができるが、一般ユーザーは自分自身のみを見ることができる
      if user.admin?
        scope.all # 全てのユーザーを表示
      else
        scope.where(id: user.id) # 自分自身のユーザーのみを表示
      end
    end
  end

  def show?
    # ユーザーの詳細を表示できるかどうかの条件
    # 例: 現在のユーザーが管理者でない場合は表示を許可しない
    !user.admin?
  end

  def update?
    # ユーザーの設定を更新できるかどうかの条件
    user == record
  end
end
