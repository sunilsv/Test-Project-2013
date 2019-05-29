data "aws_iam_policy_document" "people_lambda_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "people_lambda_role_policy" {
  name = "people_lambda_role_policy"
  role = "${aws_iam_role.people_lambda_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": "logs:PutLogEvents",
        "Resource": "arn:aws:logs:*:*:log-group:*:*:*"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:log-group:*"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "*"
      },
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "dynamodb:*"
          ],
          "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role" "people_lambda_role" {
  name               = "people_lambda_role"
  assume_role_policy = "${data.aws_iam_policy_document.people_lambda_policy.json}"
}

data "aws_iam_policy_document" "people_cloudwatch_event_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "people_cloudwatch_event_role" {
  name               = "people_cloudwatch_event_role"
  assume_role_policy = "${data.aws_iam_policy_document.people_cloudwatch_event_policy.json}"
}

resource "aws_lambda_permission" "people_allow_cloudwatch_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.people.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.people_event.arn}"
}