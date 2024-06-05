class User < ApplicationRecord
  require 'csv'
  has_many :attendances, dependent: :destroy
  attribute :scheduled_end_time, :time
  attr_accessor :remember_token #記憶トークンとユーザーをremember_tokenという仮想の属性を作成します。
  before_save { self.email = email.downcase } #selfはユーザーオブジェクトを指す
  
  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
            format: { with: VALID_EMAIL_REGEX }, #VALID_EMAIL_REGEX定数に正規表現を定義し、formatバリデーションを追加し、
            uniqueness: true                     #withで正規表現を指定することでメールアドレスのフォーマットを制限しています。
  validates :affiliation, length: { in: 2..50 }, allow_blank: true#値が空の場合はバリデーションを実行しない  #validates :employee_number, presence: true, uniqueness: true
  validates :basic_work_time, presence: true
  validates :work_time, presence: true
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
                      #presence: trueを用いることでそのカラムの値が存在するかどうかをチェックできる。
  # 渡された文字列のハッシュ化を行う。
  def User.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end                                    
    BCrypt::Password.create(string, cost: cost) #文字列をハッシュ化してBCrypt::Passwordインスタンスを返す。
  end                                           #ハッシュ化したい文字列stringとコストパラメータcostをBCrypt::Password.createメソッドに渡すと、渡した文字列をハッシュ化してくれる。
                                                #コストパラメータを高く設定すると、よりセキュリティの高いハッシュ値を生成するらしい。
  
  #ランダムな文字列（記憶トークン）を生成するUserクラスのクラスメゾットuser.digestを作る
  #Rubyの標準ライブラリのSecureRandomモジュールのurlsafe_base64メソッドを使う
  def User.new_token
    SecureRandom.urlsafe_base64
  end 
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
        #selfを記述することで仮想のremember_token属性にUser.new_tokenで生成した
        #「ハッシュ化されたトークン情報」を代入しています。
        #selfがないと、単純にremember_tokenというローカル変数が作成されてしまいます。
        
        #update_attributesと違い（よく見ると末尾にsがあるかないかの違いがあります）
        #こちらはバリデーションを素通りさせます。
        #今回はユーザーのパスワードなどにアクセス出来ないため、
        #このメソッドを用いてバリデーションを素通りさせる必要がありました。
        
  #トークンがダイジェストと一致すればtrueを返します。      
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end                    #データベース                #cookiesに保存されている。

  #ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  #ユーザー検索
  def self.search(search)
    return User.all unless search
    User.where(['name LIKE ?', "%#{search}%"])
  end

  
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = find_by(id: row["id"]) || new # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      user.attributes = row.to_hash.slice(*updatable_attributes)  # CSVからデータを取得し、設定する
      user.save!(validate: false)
    end 
  end
  
 
  # ユーザー一覧　ユーザー編集　更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid",
    "basic_work_time", "designated_work_start_time", "designated_work_end_time",
    "superior", "admin", "password"]
  end
end
