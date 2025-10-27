output "bucket_swarm_token_arn" {
  value = aws_s3_bucket.bucket_swarm_token.arn
}

output "swarm_token_bucket" {
  value = aws_s3_bucket.bucket_swarm_token.bucket
}