module "network" {
  source     = "../../modules/network"
  aws_region = var.aws_region
}

module "s3" {
  source = "../../modules/s3"
}

module "sns" {
  source = "../../modules/sns"
}

module "sqs" {
  source = "../../modules/sqs"
  subscribed_topic_arn = module.sns.tf-sns_fifo_arn
  depends_on = [module.sns]
}

module "target-group" {
  source = "../../modules/target-group"
  app_port = var.app_port

  vpc_id = module.network.vpc_id_ec2

  depends_on = [module.network]
}

module "ec2" {
  source                       = "../../modules/ec2"
  key_pair_ec2_path            = var.key_pair_path
  aws_region                   = var.aws_region
  aws_access_key_id            = var.aws_access_key_id
  aws_secret_access_key        = var.aws_secret_access_key
  app_port                     = var.app_port

  instances_subnet_id          = module.network.public_subnet_id_ec2
  vpc_id                       = module.network.vpc_id_ec2
  swarm_token_bucket_arn       = module.s3.bucket_swarm_token_arn
  swarm_token_bucket           = module.s3.swarm_token_bucket
  app_lb_tg_arn                = module.target-group.app_lb_tg_arn

  depends_on                   = [module.s3, module.network, module.target-group, module.sqs, module.sns]
}

module "storage" {
  source                    = "../../modules/storage"
  ec2_instance_az           = module.ec2.ec2_instance_az
  ec2_instance_id           = module.ec2.app_ec2_instance_id
  swarm_manager_instance_id = module.ec2.manager_ec2_instance_id

  depends_on = [module.ec2]
}

module "alb" {
  source = "../../modules/alb"
  alb_subnet_id_a = module.network.public_subnet_alb_a_id
  alb_subnet_id_b = module.network.public_subnet_alb_b_id
  app_target_group_arn = module.target-group.app_lb_tg_arn
  sg_lb_id = module.ec2.lb_sg_id

  depends_on = [module.network, module.target-group, module.ec2]
}