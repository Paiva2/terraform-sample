module "network" {
  source     = "../../modules/network"
}

module "ec2" {
  source                = "../../modules/ec2"
  subnet_id             = module.network.public_subnet_id_ec2
  vpc_id                = module.network.vpc_id_ec2
  key_pair_ec2_path     = "~/.ssh/ec2-tf.pub"
  aws_region            = var.aws_region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
}

module "sns" {
  source = "../../modules/sns"
}

module "sqs" {
  source = "../../modules/sqs"
  subscribed_topic_arn = module.sns.tf-sns_fifo_arn
}