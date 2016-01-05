defmodule OAuth2.Strategy.AuthCode do
  @moduledoc """
  The Authorization Code Strategy.

  http://tools.ietf.org/html/rfc6749#section-1.3.1

  The authorization code is obtained by using an authorization server
  as an intermediary between the client and resource owner.  Instead of
  requesting authorization directly from the resource owner, the client
  directs the resource owner to an authorization server (via its
  user-agent as defined in [RFC2616]), which in turn directs the
  resource owner back to the client with the authorization code.

  Before directing the resource owner back to the client with the
  authorization code, the authorization server authenticates the
  resource owner and obtains authorization.  Because the resource owner
  only authenticates with the authorization server, the resource
  owner's credentials are never shared with the client.

  The authorization code provides a few important security benefits,
  such as the ability to authenticate the client, as well as the
  transmission of the access token directly to the client without
  passing it through the resource owner's user-agent and potentially
  exposing it to others, including the resource owner.
  """

  use OAuth2.Strategy

  @doc """
  The authorization URL endpoint of the provider.
  params additional query parameters for the URL
  """
  def authorize_url(client, params) do
    client
    |> put_param(:response_type, "code")
    |> put_param(:client_id, client.client_id)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> merge_params(params)
  end

  @doc """
  Retrieve an access token given the specified validation code.
  """
  def get_token(client, params, headers) do
    {code, params} = case params do
      ps when is_list(ps) -> Keyword.pop(ps, :code, client.params["code"])
      ps when is_map(ps) -> Map.pop(ps, "code", client.params["code"])
    end

    unless code do
      raise OAuth2.Error, reason: "Missing required key `code` for `#{inspect __MODULE__}`"
    end

    client
    |> put_param(:code, code)
    |> put_param(:grant_type, "authorization_code")
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> merge_params(params)
    |> put_headers(headers)
  end
end

