class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest, :string
  end
end

#has_secure_passwordメソッドの機能で使用できるもので、暗号化したパスワードを保存しておくカラム