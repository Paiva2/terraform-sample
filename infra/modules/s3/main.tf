resource "aws_s3_bucket" "bucket_swarm_token" {
  bucket = "swarm-token-ec2-instances-repo"

  tags = {
    Name        = "Swarm Token Bucket"
    Environment = "staging"
  }
}