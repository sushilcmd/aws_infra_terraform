resource "aws_api_gateway_rest_api" "rest_api" {
  api_key_source = "HEADER"
  name           = "dev_tf_api"
  description    = "Test API gateway using terraform"
}

resource "aws_api_gateway_resource" "user_resource" {
  depends_on = [
    aws_api_gateway_rest_api.rest_api
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "user"
}

resource "aws_api_gateway_method" "user_resource_method" {
  depends_on = [
    aws_api_gateway_resource.user_resource
  ]
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_user_resource_method" {
  depends_on = [
    aws_api_gateway_resource.user_resource
  ]
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_resource_method_int" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.user_resource_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.create_user.invoke_arn
}

resource "aws_api_gateway_integration" "get_user_resource_method_int" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.get_user_resource_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_user.invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.user_resource_method_int,
    aws_api_gateway_integration.get_user_resource_method_int,
  ]
  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id        = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  stage_name           = "dev"
  xray_tracing_enabled = true
}

resource "aws_api_gateway_method_settings" "method_setting" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

# resource "aws_lambda_permission" "apig_permission_create_user" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda.create_user
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}/${aws_api_gateway_resource.resource.path}"
# }

# resource "aws_lambda_permission" "apig_permission_create_user" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda.get_user
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/"
# }