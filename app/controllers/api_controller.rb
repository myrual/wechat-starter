class ApiController < ApplicationController
   skip_before_action :verify_authenticity_token, only: [:wx_jssdk_sign]
 
   wechat_api
 
   def verify_api_only
      params[:pageid].present? and params[:pagesecret].present?
   end
   def wx_jssdk_sign
 
       # Get domain_name, api and app_id
       # default account
       domain_name = self.class.trusted_domain_fullname
       api = self.wechat
       app_id = self.class.corpid || self.class.appid
 
       page_url = params[:pageurl]
       js_hash = api.jsapi_ticket.signature(page_url)
       render json: {'appId':app_id, 'timestamp': "#{js_hash[:timestamp]}", 'nonceStr':"#{js_hash[:noncestr]}", signature: "#{js_hash[:signature]}"}
   end
  def wx_notify
    result = Hash.from_xml(request.body.read)['xml']
    logger.info result.inspect
    if WxPay::Sign.verify?(result)
      render xml: { return_code: 'SUCCESS', return_msg: 'OK' }.to_xml(root: 'xml', dasherize: false)
    else
      render xml: { return_code: 'FAIL', return_msg: 'Signature Error' }.to_xml(root: 'xml', dasherize: false)
    end
  end
end
