class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
#ApplicationRecordクラスが抽象クラスとして設定され、直接インスタンス化されないようになります。この設定は、Railsのモデル階層全体に共通の機能や設定を提供するために役立ちます。
