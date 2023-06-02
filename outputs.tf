output "id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_distribution.distribution.id
}

output "arn" {
  description = "The ARN of the distribution."
  value       = aws_cloudfront_distribution.distribution.arn
}

output "domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to."
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}
