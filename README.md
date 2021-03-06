# WechatPay

WechatPay API wrapper in Elixir.

:warning: Be careful, some of the Wechat's [API docs](https://pay.weixin.qq.com/wiki/doc/api/index.html) are inconsistent with the real API endpoints. I only test those APIs on a Wechat MP App.

[![Travis](https://img.shields.io/travis/linjunpop/wechat_pay.svg)](https://travis-ci.org/linjunpop/wechat_pay)
[![Hex.pm](https://img.shields.io/hexpm/v/wechat_pay.svg)](https://hex.pm/packages/wechat_pay)
[![codebeat badge](https://codebeat.co/badges/35908fb7-9d5b-4622-b75b-93b69aea416b)](https://codebeat.co/projects/github-com-linjunpop-wechat_pay-master)
[![Inline docs](http://inch-ci.org/github/linjunpop/wechat_pay.svg)](http://inch-ci.org/github/linjunpop/wechat_pay)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `wechat_pay` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:wechat_pay, "~> 0.1.0"}]
    end
    ```

  2. Ensure `wechat_pay` is started before your application:

    ```elixir
    def application do
      [applications: [:wechat_pay]]
    end
    ```

## Usage

### Config `:wechat_pay`

```elixir
use Mix.Config

config :wechat_pay,
  env: :sandbox, # or :production
  appid: "wx8888888888888888",
  mch_id: "1900000109",
  apikey: "192006250b4c09247ec02edce69f6a2d",
  ssl_cacertfile: "certs/ca.cert",
  ssl_certfile: "certs/client.crt",
  ssl_keyfile: "certs/client.key",
  ssl_password: "test"
```

> :warning:
> If the env is `:sandbox`,
> you should fill the real `appid, mch_id, apikey` here,
> then call `WechatPay.API.Client.get_sandbox_signkey()` to get the sandbox apikey,
> then replace the `apikey` with this one.
> It's verbose, but it's a workaround for using in the sandbox env.

### APIs

[https://pay.weixin.qq.com/wiki/doc/api/index.html](https://pay.weixin.qq.com/wiki/doc/api/index.html)

#### JSAPI（公众号支付）

- [x] `WechatPay.API.place_order(params)`
- [x] `WechatPay.API.query_order(params)`
- [x] `WechatPay.API.close_order(params)`
- [x] `WechatPay.API.refund(params)`
- [x] `WechatPay.API.query_refund(params)`
- [x] `WechatPay.API.download_bill(params)`
- [x] `WechatPay.API.report(params)`
- [x] `WechatPay.HTML.generate_pay_request(prepay_id)`

#### Native（扫码支付）

- [x] `WechatPay.API.place_order(params)`
- [x] `WechatPay.API.query_order(params)`
- [x] `WechatPay.API.close_order(params)`
- [x] `WechatPay.API.refund(params)`
- [x] `WechatPay.API.query_refund(params)`
- [x] `WechatPay.API.download_bill(params)`
- [x] `WechatPay.API.report(params)`
- [x] `WechatPay.API.shorten_url(url)`

#### APP（APP支付）

- [x] `WechatPay.API.place_order(params)`
- [x] `WechatPay.API.query_order(params)`
- [x] `WechatPay.API.close_order(params)`
- [x] `WechatPay.API.refund(params)`
- [x] `WechatPay.API.query_refund(params)`
- [x] `WechatPay.API.report(params)`
- [x] `WechatPay.API.download_bill(params)`

#### Example

```elixir
params = %{
  device_info: "WEB",
  body: "时习-#{event.title}",
  attach: nil,
  out_trade_no: order.order_number,
  fee_type: "CNY",
  total_fee: order.fee,
  spbill_create_ip: Keyword.get(opts, :remote_ip),
  notify_url: @notify_url,
  time_start: now |> format_datetime,
  time_expire: now |> Timex.shift(hours: 1) |> format_datetime,
  trade_type: "JSAPI",
  openid: User.openid(user),
}

case WechatPay.API.place_order(params) do
  {:ok, order} ->
    order
  {:error, reason} ->
    IO.inspect reason
end
```

## Plug

There's a plug `WechatPay.Plug.Callback` to handle callback from Wechat's server

```elixir
defmodule MyApp.Web.WechatPayController do
  use MyApp.Web, :controller

  @behaviour WechatPay.Plug.Callback.Handler

  plug WechatPay.Plug.Callback, handler: MyApp.Web.WechatPayController

  def handle_data(conn, data) do
    IO.inspect data
    # %{
    #   appid: "wx2421b1c4370ec43b",
    #   attach: "支付测试",
    #   bank_type: "CFT",
    #   fee_type: "CNY",
    #   is_subscribe: "Y",
    #   mch_id: "10000100",
    #   nonce_str: "5d2b6c2a8db53831f7eda20af46e531c",
    #   openid: "oUpF8uMEb4qRXf22hE3X68TekukE",
    #   out_trade_no: "1409811653",
    #   result_code: "SUCCESS",
    #   return_code: "SUCCESS",
    #   sign: "594B6D97F089D24B55156CE09A5FF412",
    #   sub_mch_id: "10000100",
    #   time_end: "20140903131540",
    #   total_fee: "1",
    #   trade_type: "JSAPI",
    #   transaction_id: "1004400740201409030005092168"
    # }
  end

  def handle_error(conn, reason, data) do
    reason == "签名失败"
    data.return_code == "FAIL"
  end
end
```

