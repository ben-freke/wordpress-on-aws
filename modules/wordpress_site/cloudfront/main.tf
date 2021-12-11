data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

locals {
  wordpress_special_paths = [
    "/wp-admin/*",
    "/wp-login.php*",
    "/wp-trackback.php",
    "/xmlrpc.php",
    "/wp-cron.php"
  ]
}

#tfsec:ignore:aws-cloudfront-enable-logging tfsec:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "s3_distribution" {
  web_acl_id = var.waf_id
  origin {
    origin_id = var.wordpress_site_slug
    custom_origin_config {
      http_port              = 443
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
    domain_name = var.default_domain
    custom_header {
      name  = "cf-origin-header-value"
      value = var.http_origin_header
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  aliases         = concat([var.wordpress_domain], var.redirect_subdomains)

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.wordpress_site_slug
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]
      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "comment_author_*",
          "comment_author_email_*",
          "comment_author_url_*",
          "wordpress_logged_in_*",
          "wordpress_test_cookie",
          "wp-settings-*",
          "duo_wordpress_auth_cookie"
        ]
      }
    }
    min_ttl     = 3600
    max_ttl     = 31536000
    default_ttl = 86400
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.wordpress_special_paths
    content {
      path_pattern           = ordered_cache_behavior.value
      allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["HEAD", "GET", "OPTIONS"]
      target_origin_id       = var.wordpress_site_slug
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
      forwarded_values {
        query_string = true
        headers      = ["*"]
        cookies {
          forward = "all"
        }
      }
      min_ttl     = 0
      max_ttl     = 0
      default_ttl = 0
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/wp-content/*"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = var.wordpress_site_slug
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 86400
    max_ttl     = 31536000
    default_ttl = 604800
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}