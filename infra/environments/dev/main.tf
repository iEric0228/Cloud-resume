#DynamoDB table for vistor counter

module "dynamodb" {
    source = "../../modules/dynamodb"
    environment = var.environment
}

#S3 bucket for static website hosting
module "s3" {
    source      = "../../modules/s3"
    bucket_name = var.bucket_name
    environment = var.environment
}

module "lambda" {
    source               = "../../modules/lambda"
    environment          = var.environment
    dynamodb_table_name  = module.dynamodb.table_name    # ← From DynamoDB
    dynamodb_table_arn   = module.dynamodb.table_arn     # ← From DynamoDB
}

module "api_gateway" {
    source               = "../../modules/api-gateway"
    environment          = var.environment
    lambda_function_name = module.lambda.function_name    # ← From Lambda
    lambda_invoke_arn    = module.lambda.function_invoke_arn  # ← From Lambda
}

module "cloudfront" {
    source             = "../../modules/cloudfront"
    bucket_domain_name = module.s3.bucket_domain_name    # ← From S3
}
