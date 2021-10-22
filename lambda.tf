locals {
  source_file_base_path   = "./resource"
  create_user_name        = "create_user"
  get_user_name           = "get_user"
  create_user_output_path = "outputs/createUser.zip"
  get_user_output_path    = "outputs/getUser.zip"

}

data "archive_file" "create_user_file" {
  type        = "zip"
  source_file = "${local.source_file_base_path}/createUser/index.js"
  output_path = local.create_user_output_path
}

data "archive_file" "get_user_file" {
  type        = "zip"
  source_file = "${local.source_file_base_path}/getUser/index.js"
  output_path = local.get_user_output_path
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "tf_lambda_execution_role"
  assume_role_policy = file("iam/lambda-assume-policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  policy = file("iam/lambda-policy.json")
  role   = aws_iam_role.lambda_execution_role.id
}

resource "aws_lambda_function" "create_user" {
  function_name = local.create_user_name
  filename      = local.create_user_output_path
  source_code_hash = "${filebase64sha256(local.create_user_output_path)}"
  role    = aws_iam_role.lambda_execution_role.arn
  handler = "index.handler"
  runtime = "nodejs14.x"
}

resource "aws_lambda_function" "get_user" {
  function_name = local.get_user_name
  filename      = local.get_user_output_path
  source_code_hash = "${filebase64sha256(local.get_user_output_path)}"
  role    = aws_iam_role.lambda_execution_role.arn
  handler = "index.handler"
  runtime = "nodejs14.x"
}

resource "aws_cloudwatch_log_group" "create_user_log_group" {
  name              = "/aws/lambda/${local.create_user_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_user_log_group" {
  name              = "/aws/lambda/${local.get_user_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy" "xray_policy" {
  name   = "xray_policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = file("iam/xray-policy.json")
}