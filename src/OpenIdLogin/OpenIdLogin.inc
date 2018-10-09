
CONSTANT C_OPENIDLOGIN = "https://generodemo.hopto.org/g/ua/r/OpenIdLogin"
CONSTANT C_OPENID = "#OpenId#"
TYPE t_oidc RECORD
		email STRING,
		family STRING,
		given STRING,
		idp_issuer STRING,
		idp_token_endpoint STRING,
		name STRING,
		picture STRING,
		profile STRING,
		sub STRING,
		token_expires_in INTEGER,
		userinfo_endpoint STRING
	END RECORD

