module I18n
  module Globalizable
    def t(options = {})
      I18n.t(self, options.merge(default: self.split('.').last))
    end
  end
end

String.send :include, I18n::Globalizable
Symbol.send :include, I18n::Globalizable