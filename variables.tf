
variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
}

variable "default_root_object" {
  default     = null
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}

variable "enabled" {
  default     = true
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
}

variable "http_version" {
  default     = "http2and3"
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http3."
  type        = string

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "Value must be one of: 'http1.1', 'http2', 'http2and3', 'http3'."
  }
}

variable "is_ipv6_enabled" {
  default     = null
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
}

variable "price_class" {
  default     = null
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Value must be one of: 'PriceClass_All', 'PriceClass_200', 'PriceClass_100'."
  }
}

variable "web_acl_id" {
  default     = null
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
}

variable "origins" {
  description = "One or more origins for this distribution"
  type = list(object({
    domain_name               = string
    origin_id                 = string
    origin_path               = optional(string)
    s3_origin_access_identity = optional(string)
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
      origin_ssl_protocols   = list(string)
    }))

    custom_headers = optional(list(object({
      name  = string
      value = string
    })))
  }))
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type = object({
    acm_certificate_arn      = string
    minimum_protocol_version = string
    ssl_support_method       = string
  })
}

variable "logging_config" {
  default     = null
  description = "The logging configuration that controls how logs are written to your distribution (maximum one)."
  type = object({
    bucket          = string
    include_cookies = optional(bool)
    prefix          = optional(string)
  })
}

variable "custom_error_response" {
  default     = {}
  description = "One or more custom error response elements"
  type        = any
}

variable "default_cache_behavior" {
  description = "The default cache behavior for this distribution"
  type = object({
    allowed_methods            = list(string)
    cached_methods             = list(string)
    target_origin_id           = string
    viewer_protocol_policy     = string
    response_headers_policy_id = optional(string)

    compress = optional(bool)

    lambda_function_association = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool)
    })))
  })
}

variable "default_cache_policy" {
  description = "The default cache policy configuration"
  type = object({
    default_ttl = optional(number)
    min_ttl     = optional(number)
    max_ttl     = optional(number)
    parameters_in_cache_key_and_forwarded_to_origin = object({
      enable_accept_encoding_brotli = bool
      enable_accept_encoding_gzip   = bool
      cookie_behavior               = string
      cookie_items                  = optional(list(string))

      header_behavior = string
      header_items    = optional(list(string))

      query_string_behavior = string
      query_string_items    = optional(list(string))
    })
  })

  default = {
    default_ttl = 3600
    min_ttl     = 1
    max_ttl     = 86400
    parameters_in_cache_key_and_forwarded_to_origin = {
      enable_accept_encoding_brotli = true
      enable_accept_encoding_gzip   = true
      cookie_behavior               = "none"
      header_behavior               = "whitelist"
      header_items                  = ["Accept", "Accept-Language", "Authorization", "Host", "Origin"]
      query_string_behavior         = "all"
    }
  }

  validation {
    condition     = contains(["none", "whitelist", "allExcept", "all"], var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookie_behavior)
    error_message = "Value of cookie_behavior must be one of: 'none', 'whitelist', 'allExcept', 'all'."
  }

  validation {
    condition     = contains(["none", "whitelist"], var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.header_behavior)
    error_message = "Value of header_behavior must be one of: 'none', 'whitelist'."
  }

  validation {
    condition     = contains(["none", "whitelist", "allExcept", "all"], var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_string_behavior)
    error_message = "Value of query_string_behavior must be one of: 'none', 'whitelist', 'allExcept', 'all'."
  }
}

variable "default_origin_request_policy" {
  description = "The default origin request policy configuration"
  type = object({
    cookie_behavior = string
    cookie_items    = optional(list(string))

    header_behavior = string
    header_items    = optional(list(string))

    query_string_behavior = string
    query_string_items    = optional(list(string))
  })

  default = {
    cookie_behavior       = "all"
    header_behavior       = "allViewer"
    query_string_behavior = "all"
  }

  validation {
    condition     = contains(["none", "whitelist", "all"], var.default_origin_request_policy.cookie_behavior)
    error_message = "Value of cookie_behavior must be one of: 'none', 'whitelist', 'all'."
  }

  validation {
    condition     = contains(["none", "whitelist", "allViewer", "allViewerAndWhitelistCloudFront"], var.default_origin_request_policy.header_behavior)
    error_message = "Value of header_behavior must be one of: 'none', 'whitelist', 'allViewer', 'allViewerAndWhitelistCloudFront'."
  }

  validation {
    condition     = contains(["none", "whitelist", "all"], var.default_origin_request_policy.query_string_behavior)
    error_message = "Value of query_string_behavior must be one of: 'none', 'whitelist', 'all'."
  }
}
