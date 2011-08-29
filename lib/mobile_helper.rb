module MobileHelper
  include MetaDataHelper

  module Apple
    def apple_app_capable_meta_tag
      meta_tag 'apple-mobile-web-app-capable', 'yes'
    end

    def apple_app_icon_link_tag
      link_tag 'apple-touch-icon', image_path('icon.png')
    end
  end
  include Apple

  def viewport_meta_tag
    meta_tag :viewport, [
      'width=device-width',
      'initial-scale=1.0',
      'maximum-scale=1.0',
      'minimum-scale=1.0',
      'user-scalable=no'
    ].join(',')
  end

end