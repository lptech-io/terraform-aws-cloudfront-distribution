<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_request_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Extra CNAMEs (alternate domain names), if any, for this distribution. | `list(string)` | n/a | yes |
| <a name="input_comment"></a> [comment](#input\_comment) | Any comments you want to include about the distribution. | `string` | n/a | yes |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | One or more custom error response elements | `any` | `{}` | no |
| <a name="input_default_cache_behavior"></a> [default\_cache\_behavior](#input\_default\_cache\_behavior) | The default cache behavior for this distribution | <pre>object({<br>    allowed_methods            = list(string)<br>    cached_methods             = list(string)<br>    target_origin_id           = string<br>    viewer_protocol_policy     = string<br>    response_headers_policy_id = optional(string)<br><br>    compress = optional(bool)<br><br>    lambda_function_association = optional(list(object({<br>      event_type   = string<br>      lambda_arn   = string<br>      include_body = optional(bool)<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_default_cache_policy"></a> [default\_cache\_policy](#input\_default\_cache\_policy) | The default cache policy configuration | <pre>object({<br>    default_ttl = optional(number)<br>    min_ttl     = optional(number)<br>    max_ttl     = optional(number)<br>    parameters_in_cache_key_and_forwarded_to_origin = object({<br>      enable_accept_encoding_brotli = bool<br>      enable_accept_encoding_gzip   = bool<br>      cookie_behavior               = string<br>      cookie_items                  = optional(list(string))<br><br>      header_behavior = string<br>      header_items    = optional(list(string))<br><br>      query_string_behavior = string<br>      query_string_items    = optional(list(string))<br>    })<br>  })</pre> | <pre>{<br>  "default_ttl": 3600,<br>  "max_ttl": 86400,<br>  "min_ttl": 1,<br>  "parameters_in_cache_key_and_forwarded_to_origin": {<br>    "cookie_behavior": "none",<br>    "enable_accept_encoding_brotli": true,<br>    "enable_accept_encoding_gzip": true,<br>    "header_behavior": "whitelist",<br>    "header_items": [<br>      "Accept",<br>      "Accept-Language",<br>      "Authorization",<br>      "Host",<br>      "Origin"<br>    ],<br>    "query_string_behavior": "all"<br>  }<br>}</pre> | no |
| <a name="input_default_origin_request_policy"></a> [default\_origin\_request\_policy](#input\_default\_origin\_request\_policy) | The default origin request policy configuration | <pre>object({<br>    cookie_behavior = string<br>    cookie_items    = optional(list(string))<br><br>    header_behavior = string<br>    header_items    = optional(list(string))<br><br>    query_string_behavior = string<br>    query_string_items    = optional(list(string))<br>  })</pre> | <pre>{<br>  "cookie_behavior": "all",<br>  "header_behavior": "allViewer",<br>  "query_string_behavior": "all"<br>}</pre> | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content. | `bool` | `true` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http3. | `string` | `"http2and3"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Whether the IPv6 is enabled for the distribution. | `bool` | `null` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | The logging configuration that controls how logs are written to your distribution (maximum one). | <pre>object({<br>    bucket          = string<br>    include_cookies = optional(bool)<br>    prefix          = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | One or more origins for this distribution | <pre>list(object({<br>    domain_name               = string<br>    origin_id                 = string<br>    origin_path               = optional(string)<br>    s3_origin_access_identity = optional(string)<br>    custom_origin_config = optional(object({<br>      http_port              = number<br>      https_port             = number<br>      origin_protocol_policy = string<br>      origin_ssl_protocols   = list(string)<br>    }))<br><br>    custom_headers = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | The price class for this distribution. One of PriceClass\_All, PriceClass\_200, PriceClass\_100 | `string` | `null` | no |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | The SSL configuration for this distribution | <pre>object({<br>    acm_certificate_arn      = string<br>    minimum_protocol_version = string<br>    ssl_support_method       = string<br>  })</pre> | n/a | yes |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the distribution. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The domain name corresponding to the distribution. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. |
| <a name="output_id"></a> [id](#output\_id) | The identifier for the distribution. |
<!-- END_TF_DOCS -->