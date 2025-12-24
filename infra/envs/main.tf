module "s3" {
  source      = "../modules/s3"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source = "../modules/cloudfront"

  bucket_domain_name = module.s3.bucket_domain_name
}