resource "aws_iam_role" "allow_lambda_role" {
  name               = "${var.project}_${var.environment}_allow_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.allow_lambda_todo.json

  tags = {
    Name = "${var.project}_${var.environment}_allow_lambda_role"
  }
}

data "aws_iam_policy_document" "allow_lambda_todo" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "allow_lambda_logs" {
  name       = "${var.project}_${var.environment}_allow_lambda_logs"
  roles      = [aws_iam_role.allow_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "allow_lambda_dynamodb" {
  name   = "${var.project}_${var.environment}_allow_lambda_dynamodb"
  role   = aws_iam_role.allow_lambda_role.id
  policy = data.aws_iam_policy_document.allow_lambda_dynamodb.json
}


data "aws_iam_policy_document" "allow_lambda_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      var.dynamodb_table_arn,
      "${var.dynamodb_table_arn}/index/*"
    ]
  }
}
