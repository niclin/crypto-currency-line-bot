class CurrencyData::Huobi < CurrencyData::Base
  class << self
    def price(currency, fiat_currancy = nil)
      fiat = fiat_currancy || default_fiat_currency

      begin
        response_body = get_huobi_ticker(currency)
        average_price = (response_body["tick"]["ask"].first.to_d + response_body["tick"]["bid"].first.to_d) / 2
        average_price = average_price.to_f

        price = FiatCurrencyConverter.exchange(amount: average_price, from: default_fiat_currency, to: fiat)
        price = number_to_delimited(price)

        human_fiat_currency = fiat.upcase

        message = "[Huobi_Price] #{price} (#{human_fiat_currency})"
      rescue
        nil
      end
    end

    private

    def default_fiat_currency
      "usdt"
    end

    def huobi_api_endpoint(currency)
      raise Error, "#{currency} is not supported" unless Settings.crypto_currencies.include?(currency)

      "https://api.huobi.pro/market/detail/merged?symbol=#{currency}usdt"
    end

    # Response example
    # /* GET /market/detail/merged?symbol=ethusdt */
    # {
    # "status":"ok",
    # "ch":"market.ethusdt.detail.merged",
    # "ts":1499225276950,
    # "tick":{
    #   "id":1499225271,
    #   "ts":1499225271000,
    #   "close":1885.0000,
    #   "open":1960.0000,
    #   "high":1985.0000,
    #   "low":1856.0000,
    #   "amount":81486.2926,
    #   "count":42122,
    #   "vol":157052744.85708200,
    #   "ask":[1885.0000,21.8804],
    #   "bid":[1884.0000,1.6702]
    #   }
    # }

    def get_huobi_ticker(currency)
      response = RestClient.get(huobi_api_endpoint(currency))

      raise Error, "APIError, response: #{response}" if response.code != 200

      JSON.parse(response)
    end
  end
end
