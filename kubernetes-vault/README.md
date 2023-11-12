# 1. Инициализируем vault

	kubectl -n vault exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1

```
Unseal Key 1: e1VRXeFAIJ+i1icGsxGIG6gmARpmUnbWQOl4lmRnZq0=
Initial Root Token: hvs.1FxKKAv0NiaLKoKEpbfPo0cG

Vault initialized with 1 key shares and a key threshold of 1. Please securely distribute the key shares printed above. When the Vault is re-sealed, restarted, or stopped, you must supply at least 1 of these keys to unseal it before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of existing unseal keys shares. See "vault operator rekey" for more information.
```

# 2. Распечатаем vault

	kubectl exec -n vault -it vault-0 -- vault operator unseal

```
Unseal Key (will be hidden):
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.15.1
Build Date      2023-10-20T19:16:11Z
Storage Type    file
Cluster Name    vault-cluster-2022d497
Cluster ID      46cde326-9e8a-8864-c9b0-a8b9512d9c8f
HA Enabled      true
```


# 3. Залогинимся в vault (у нас есть root token)

	kubectl exec -n vault -it vault-0 -- vault login

```
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.1FxKKAv0NiaLKoKEpbfPo0cG
token_accessor       KBtrG4jQ5kG1Mg6J8FdtNyZ5
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```


	kubectl exec -n vault -it vault-0 -- vault auth list
	
```
Path      Type     Accessor               Description            Version
----      ----     --------               -----------            -------
token/    token    auth_token_9a282706    token based credentials    n/a
```

# 4. Заведем секреты
	
	kubectl exec -n vault -it vault-0 -- vault read otus/otus-ro/config

```
Key                 Value
---                 -----
refresh_interval    768h
password            asajklkahs
username            otus
```


# 5. Включим авторизацию через k8s

	kubectl exec -n vault -it vault-0 -- vault auth enable kubernetes

```
Success! Enabled kubernetes auth method at: kubernetes/
```

	kubectl exec -n vault -it vault-0 -- vault auth list
	
```
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_753de821    n/a                        n/a
token/         token         auth_token_9a282706         token based credentials    n/a
```

# 6. Создадим и отзовем новые сертификаты

	kubectl exec -n vault -it vault-0 -- vault write pki_int/roles/example-dot-ru allowed_domains=test.foo.com allow_subdomains=false allow_bare_domains=true max_ttl=72h

```
Key                                   Value
---                                   -----
allow_any_name                        false
allow_bare_domains                    true
allow_glob_domains                    false
allow_ip_sans                         true
allow_localhost                       true
allow_subdomains                      false
allow_token_displayname               false
allow_wildcard_certificates           true
allowed_domains                       [test.foo.com]
allowed_domains_template              false
allowed_other_sans                    []
allowed_serial_numbers                []
allowed_uri_sans                      []
allowed_uri_sans_template             false
allowed_user_ids                      []
basic_constraints_valid_for_non_ca    false
client_flag                           true
cn_validations                        [email hostname]
code_signing_flag                     false
country                               []
email_protection_flag                 false
enforce_hostnames                     true
ext_key_usage                         []
ext_key_usage_oids                    []
generate_lease                        false
issuer_ref                            default
key_bits                              2048
key_type                              rsa
key_usage                             [DigitalSignature KeyAgreement KeyEncipherment]
locality                              []
max_ttl                               72h
no_store                              false
not_after                             n/a
not_before_duration                   30s
organization                          []
ou                                    []
policy_identifiers                    []
postal_code                           []
province                              []
require_cn                            true
server_flag                           true
signature_bits                        256
street_address                        []
ttl                                   0s
use_csr_common_name                   true
use_csr_sans                          true
use_pss                               false
```

	kubectl exec -n vault  -it vault-0 -- vault write pki_int/issue/example-dot-ru common_name="test.foo.com" ttl="24h"

```
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUWgDwA6fPsJh4QfHo+RRd9CgKYzEwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhhbXBsZS5ydTAeFw0yMzExMTIxNDA3MDFaFw0yODEx
MTAxNDA3MzFaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANwhy3QVofa1
ZnSoo82MyyzpP42n5O+b5L9J75blLqVe1xRqJfhmR5vccljVXbPr58WAu8h3QiaH
p4ZdsonKWbytuz3GrnOPjN5gfk1A5eTpsHjlUIq+0jugepZCvcNm+u9XH5mMBn0w
C0uxEduyw3E2nQDyofRB/CqXJfscJl5hSsHEwSKjSszYWIGeswCS/+hlXV6sb55y
T6+LG+QWTflqgKFZi7yGtirj1boOzarcLKjfBHx0sIL/TzeHUp5KSInBn+fuaVSi
Db4BMMtf7voS9AyzRS3c93ABcAY/XMoFcLKGNIhnX0dvpwggBelGTGJx6q2FEZyP
xqUxgrqI9asCAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUC0/em1QV95p0dbXWNOC/NrzZMaQwHwYDVR0jBBgwFoAU
Yul7o+jhZOpWjUoBb+Osus56/QkwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
H5E8JpabVW/1GDOdYbamyfKgPUWP67lqj7+DMCfNujQqpUkVzCZ6Z9jzSwzp7vlr
IKDTUHsHFXVDUW79FY7vyU8sYDB6MUitSQff/QxecUt4DMxO57H/qTG3rrj4OeY/
8AYcihARVAt6S9PZDQDkaFB6jr6fJ6aaxye7/vnsgqWsIIuUc11xu1Zb47b+I2MX
kDshRZjUyQYSHvoeFhTu+N9NgNGphLGGSuaGXXRAWsDhWtdbjWJIhHMz6bezbwaJ
BzSBkQi2FA1nNNXgmfyfuL1aTWo0gH+yyadAo+ZVLSf132z7Pk/QTLoi68H6l4/B
JQSIbrxMaXIPuP51pwxoaA==
-----END CERTIFICATE----- -----BEGIN CERTIFICATE-----
MIIDMjCCAhqgAwIBAgIUCGtcxGW2Vz3zKr9QVG/f68EQjaQwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhhbXBsZS5ydTAeFw0yMzExMTIxMzU2MTlaFw0zMzEx
MDkxMzU2NDhaMBUxEzARBgNVBAMTCmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCzeusqANZxaGcxKOAdBHEoHxQ049mU/AjkrwW9kxI1
OrtrhvMKAQYa42RqgETnNirU9zkJj67eluxpRzR9B82K7V6JuGfg0k9m7GyVM4E8
LKQX0O6qBenueIJ3iObNTxk0C65yLc/KHdle1yIZ3LRWZTIwJPhZlrAGlho3Z+Wf
yG7xDEJ+GMq2oXnrKqcypsrz5D85GGSiA5ccn2wU0CPGpSBcbigP3e/heA29KWXz
/FdzleNF5CivABESx5M+RKjEAEfSW90IZ7pE+oL0P6fT6DgD37IbnbA97NIw1hmU
nUqIUIa4A6LKa7Z++YV5lQ7IzQbe0HdECoFz7xQaf4QXAgMBAAGjejB4MA4GA1Ud
DwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRi6Xuj6OFk6laN
SgFv46y6znr9CTAfBgNVHSMEGDAWgBRi6Xuj6OFk6laNSgFv46y6znr9CTAVBgNV
HREEDjAMggpleGFtcGxlLnJ1MA0GCSqGSIb3DQEBCwUAA4IBAQAZZYHeEtruN5Zo
A/41qKiyh91GgL2+ZIf6agmTu0Tcf25VM0xJwwnVoy9s/iSb/1d1Qt57Cy+gfQFr
JF+5jJ8oUWVB0ZCWOP+HslVd1ueepIxtr+sASrIgu25jnqdpnIGk8vf2BRUqxMss
mFzQTDBONjR8T8zrIBvajiVZ5LSl5EHBTj0nOex9F0s9oMDvg/jdoVFyYqEDEbZO
F/6+7MIHGNX0IKqtIz4fl6A313z3PgxaEyaj3Z1MQt81x/0HvEAdC0hMSWgODLLh
2UerEOGs+2Krr2R1yz4Yi1cZCjF3FbPmzHf6QKhyFJvegdao7gLOVFIaq+bc88ws
YMNW3oQH
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIUCO8jVZ2yrIvov0j28XAqSG/pns8wDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIzMTExMjE0MjY0MFoXDTIzMTExMzE0MjcxMFowFzEVMBMGA1UEAxMMdGVz
dC5mb28uY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwFYZzECp
aSwzRpiD8+a1PbLk2Lpae296eH2p0Gpc9nzGDl4syWmt4j1mUDk9KNV5THmxKiui
m3ckcqN4rHIw6oN+u68fx4Whd6bwHHXDEVHjK4UrTFakb3KWJyqpvDNftrzk+rQy
lsBRF03MDNa8fu59tt2xCOAR9dL8ZadxQUPBiKNvdoa3yTYw++/r6kyOxiiHIy18
Z+8OU1UNheMGS3NQr55cTwtXyd6+vGMAw/bCNvSlv5kEt7qKE23hlIZVBo7TNSmr
oKkJ9BYIyM53+ti4anRhj6LeLmroN2SL5kGzzwj39I3YfkbcxwAXsuCiqOg3VYs8
AQVWZTU3Z2cXTwIDAQABo4GLMIGIMA4GA1UdDwEB/wQEAwIDqDAdBgNVHSUEFjAU
BggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFD79uAHzZe1gpVdYcOQwNDMV
jvkpMB8GA1UdIwQYMBaAFAtP3ptUFfeadHW11jTgvza82TGkMBcGA1UdEQQQMA6C
DHRlc3QuZm9vLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAHw8EUjrvtCG0rcnMhofH
XYeFmJQqh1JWMB5lciJQu2fDfmx2t9mGH1Z8AeOJTrLaU7tV9M5f1RlsOwc97Y/2
LWbR2uFcuf65IS5SdnlEqD3vERdm4btK6oW+GpVOg3cgrl1EFoa4RCKBOJA2tAoD
OOBg1ul+E4yhQizvjA4naVsKaeKqCV55RCyYqZtAyPGQKZe4Do/rZs7w1wBbJTsj
G2GKjkm2esAPGCcZbOFvUM2pkmhEqArUYphI+gjzxIR+b/nYlFnYEsS5MAWrUqFR
RhI/rC5Q4jJwJf7j+UdC45JpzGSXSxZoe9uVV3v4+mr92BQYo8yb90oMfEuZji05
yQ==
-----END CERTIFICATE-----
expiration          1699885630
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUWgDwA6fPsJh4QfHo+RRd9CgKYzEwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhhbXBsZS5ydTAeFw0yMzExMTIxNDA3MDFaFw0yODEx
MTAxNDA3MzFaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANwhy3QVofa1
ZnSoo82MyyzpP42n5O+b5L9J75blLqVe1xRqJfhmR5vccljVXbPr58WAu8h3QiaH
p4ZdsonKWbytuz3GrnOPjN5gfk1A5eTpsHjlUIq+0jugepZCvcNm+u9XH5mMBn0w
C0uxEduyw3E2nQDyofRB/CqXJfscJl5hSsHEwSKjSszYWIGeswCS/+hlXV6sb55y
T6+LG+QWTflqgKFZi7yGtirj1boOzarcLKjfBHx0sIL/TzeHUp5KSInBn+fuaVSi
Db4BMMtf7voS9AyzRS3c93ABcAY/XMoFcLKGNIhnX0dvpwggBelGTGJx6q2FEZyP
xqUxgrqI9asCAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUC0/em1QV95p0dbXWNOC/NrzZMaQwHwYDVR0jBBgwFoAU
Yul7o+jhZOpWjUoBb+Osus56/QkwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
H5E8JpabVW/1GDOdYbamyfKgPUWP67lqj7+DMCfNujQqpUkVzCZ6Z9jzSwzp7vlr
IKDTUHsHFXVDUW79FY7vyU8sYDB6MUitSQff/QxecUt4DMxO57H/qTG3rrj4OeY/
8AYcihARVAt6S9PZDQDkaFB6jr6fJ6aaxye7/vnsgqWsIIuUc11xu1Zb47b+I2MX
kDshRZjUyQYSHvoeFhTu+N9NgNGphLGGSuaGXXRAWsDhWtdbjWJIhHMz6bezbwaJ
BzSBkQi2FA1nNNXgmfyfuL1aTWo0gH+yyadAo+ZVLSf132z7Pk/QTLoi68H6l4/B
JQSIbrxMaXIPuP51pwxoaA==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAwFYZzECpaSwzRpiD8+a1PbLk2Lpae296eH2p0Gpc9nzGDl4s
yWmt4j1mUDk9KNV5THmxKiuim3ckcqN4rHIw6oN+u68fx4Whd6bwHHXDEVHjK4Ur
TFakb3KWJyqpvDNftrzk+rQylsBRF03MDNa8fu59tt2xCOAR9dL8ZadxQUPBiKNv
doa3yTYw++/r6kyOxiiHIy18Z+8OU1UNheMGS3NQr55cTwtXyd6+vGMAw/bCNvSl
v5kEt7qKE23hlIZVBo7TNSmroKkJ9BYIyM53+ti4anRhj6LeLmroN2SL5kGzzwj3
9I3YfkbcxwAXsuCiqOg3VYs8AQVWZTU3Z2cXTwIDAQABAoIBAQCNp9xgPs+HEnLB
b9rfa+/YfUVnCflSKAy/aW4EfhHxyHvmYR4DSb4zfp04QK/2vyMTXB1Lvc+JSPqj
JBrgh0nXrvlMKfLx9E2z3lPB4knFG9aAWxhEpRt+qZpFRnq0jfHUmNLcgpMvzHzs
+PNsEUvLAMO+RxD4RG916erSw7v6IDA4Zyz0R1lXku//Rur20q1deIXrqV4Scu6r
XfmJD/JwtRwh0bIrDHKb/xpEDKPhkggGdAqV3q1sTeWADllR/eSHbQGjE+QHhebV
kFJw3hp92V4UcwGdIalLOvCjik1Ndl/l56dABHgEvmeK7MD3GXMWeKzNyJJlLP1c
T1C2tmUBAoGBAMbNvITZgr8qDGJArhejrT3XX6y9llQ84Jz1qPG3NAQaH885LW3H
l+KipTIbYORs673Pua5HCd2umIh+VOo910gG7/L1mfZoVriPfQxaVdjunLjCTug9
Pj5EiIo/yKQveCQ1AC9hxVjfOttsLkiz+t0tp+3tJFZqfVviY6quSfwhAoGBAPes
CJk2+GaFQiodCtQN8tv+2v68qP1LO+vu7VxejhtfC/GGfblyDXKa5oYDrzl6P+W+
wzlwZ+4O0nDYGE0by6KT4h8bh8c8C43F+nfqxCu+wiQH3LeWOIxpk0zFH4n853zo
71HLAQ6lRW61301EeDTGcBvjjAsLUoZaRfi3oiVvAoGBAIRs8UGxPdWm5b7hBNZ8
Ud8awwFm/Gc6cgg734C7n2uIF15K4Qb6aCMwYkgBUsZ2A4ZZg38ilODU94gcVuX9
sZSqAlXd4ePwVqvz8ME0v3CUaVLtI/CxMu/5aNZmbHlpoWbE402sm+96K1OUOTR2
pwmD6xOi3oytvLljES7VkDThAoGBALG1jrXg63skQsVU8WAWYhvYUepWFCsqwGQZ
m9abQfwBxuAWUD+vxlZlLuMZ4bCsNwzyQ8IDFY+KsxSk+UraltKgqa8IYfRi8SdY
1s8UdI2u4j5YJdbUwt59ImQDTQ4FmVPXD2Dw+GE51QgLF56pclbry6U3MFT8Wsps
G6jKml2hAoGAeQ4W/JIT9RkDYWRxfWrF3Au4VMg+zsReA8uRiTuU+01t5l6J8Hvz
XAZG8PkSml0r6aP9GKWZUF1VVGG3ap+cya81ufVF/oNO8oIeZQr9QtOCEgDSpvNs
+GKI7ve6mADYUUwTisFPo/N8vES4FCXA6QxbIfSj7Bq4ebVutRJrOFw=
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       08:ef:23:55:9d:b2:ac:8b:e8:bf:48:f6:f1:70:2a:48:6f:e9:9e:cf
```

kubectl -n vault  exec -it vault-0 -- vault write pki_int/revoke serial_number="08:ef:23:55:9d:b2:ac:8b:e8:bf:48:f6:f1:70:2a:48:6f:e9:9e:cf"

```
Key                        Value
---                        -----
revocation_time            1699799410
revocation_time_rfc3339    2023-11-12T14:30:10.762574463Z
state                      revoked
```
