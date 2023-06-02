locals {
  reference = replace(replace(replace(var.aliases[0], "*.", ""), ".", "-"), "*", "") # TODO: Find a better solution
}

resource "aws_cloudfront_cache_policy" "default" {
  name        = local.reference
  comment     = "${local.reference} cache policy"
  default_ttl = var.default_cache_policy.default_ttl
  max_ttl     = var.default_cache_policy.max_ttl
  min_ttl     = var.default_cache_policy.min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.enable_accept_encoding_brotli
    enable_accept_encoding_gzip   = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.enable_accept_encoding_gzip
    cookies_config {
      cookie_behavior = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookie_behavior
      dynamic "cookies" {
        for_each = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookie_items != null ? [1] : []
        content {
          items = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookie_items
        }
      }
    }
    headers_config {
      header_behavior = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.header_behavior
      dynamic "headers" {
        for_each = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.header_items != null ? [1] : []
        content {
          items = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.header_items
        }
      }
    }
    query_strings_config {
      query_string_behavior = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_string_behavior
      dynamic "query_strings" {
        for_each = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_string_items != null ? [1] : []
        content {
          items = var.default_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_string_items
        }
      }
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "default" {
  name    = local.reference
  comment = "${local.reference} origin policy"
  cookies_config {
    cookie_behavior = var.default_origin_request_policy.cookie_behavior
    dynamic "cookies" {
      for_each = var.default_origin_request_policy.cookie_items != null ? [1] : []
      content {
        items = var.default_origin_request_policy.cookie_items
      }
    }
  }
  headers_config {
    header_behavior = var.default_origin_request_policy.header_behavior
    dynamic "headers" {
      for_each = var.default_origin_request_policy.header_items != null ? [1] : []
      content {
        items = var.default_origin_request_policy.header_items
      }
    }
  }
  query_strings_config {
    query_string_behavior = var.default_origin_request_policy.query_string_behavior
    dynamic "query_strings" {
      for_each = var.default_origin_request_policy.query_string_items != null ? [1] : []
      content {
        items = var.default_origin_request_policy.query_string_items
      }
    }
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases = var.aliases
  comment = var.comment
  enabled = var.enabled

  default_root_object = var.default_root_object

  http_version    = var.http_version
  is_ipv6_enabled = var.is_ipv6_enabled
  price_class     = var.price_class

  web_acl_id = var.web_acl_id

  dynamic "logging_config" {
    for_each = var.logging_config != null ? [1] : []

    content {
      bucket          = var.logging_config.bucket
      prefix          = var.logging_config.prefix
      include_cookies = var.logging_config.include_cookies
    }
  }

  dynamic "origin" {
    for_each = { for index, value in var.origins : index => value }

    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_access_identity != null ? [1] : []

        content {
          origin_access_identity = origin.value.s3_origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [1] : []

        content {
          http_port              = origin.value.custom_origin_config.http_port
          https_port             = origin.value.custom_origin_config.https_port
          origin_protocol_policy = origin.value.custom_origin_config.origin_protocol_policy
          origin_ssl_protocols   = origin.value.custom_origin_config.origin_ssl_protocols
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers != null ? { for index, value in origin.value.custom_headers : index => value } : {}

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    allowed_methods = var.default_cache_behavior.allowed_methods
    cached_methods  = var.default_cache_behavior.cached_methods
    compress        = var.default_cache_behavior.compress

    cache_policy_id            = aws_cloudfront_cache_policy.default.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.default.id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_association != null ? { for index, value in var.default_cache_behavior.lambda_function_association : index => value } : []

      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.viewer_certificate.acm_certificate_arn
    minimum_protocol_version = var.viewer_certificate.minimum_protocol_version
    ssl_support_method       = var.viewer_certificate.ssl_support_method
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_code = custom_error_response.value["error_code"]

      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
