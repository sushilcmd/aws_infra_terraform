resource "aws_api_gateway_rest_api" "proxy_api" {
  name        = "proxy_api"
  description = "Test Proxy API gateway using terraform"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  depends_on = [
    aws_api_gateway_rest_api.rest_api
  ]
  rest_api_id = aws_api_gateway_rest_api.proxy_api.id
  parent_id   = aws_api_gateway_rest_api.proxy_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.proxy_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.proxy_api.id
  resource_id             = aws_api_gateway_method.proxy_method.resource_id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_user.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root_method" {
  rest_api_id   = aws_api_gateway_rest_api.proxy_api.id
  resource_id   = aws_api_gateway_rest_api.proxy_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root_integration" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api.id
  resource_id = aws_api_gateway_method.proxy_root_method.resource_id
  http_method = aws_api_gateway_method.proxy_root_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user.invoke_arn
}

resource "aws_api_gateway_deployment" "proxy_api_gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.create_user_integration,
    aws_api_gateway_integration.lambda_root_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.proxy_api.id
}

resource "aws_api_gateway_stage" "proxy_api_gateway_stage" {
  deployment_id        = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  stage_name           = "dev"
  xray_tracing_enabled = true
}

resource "aws_api_gateway_method_settings" "proxy_method_setting" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api.id
  stage_name  = aws_api_gateway_stage.proxy_api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_lambda_permission" "test_funcion_invoke_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.proxy_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_user_funcion_invoke_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.proxy_api.execution_arn}/*/*"
}