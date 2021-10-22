resource "aws_dynamodb_table" "user_table" {
  name           = "user"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 2
  hash_key       = "PK"
  range_key      = "SK"
  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name   = "dev_tf_test_dynamo_db_policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = file("iam/dynamo-policy.json")
}