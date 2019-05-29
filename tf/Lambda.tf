resource "aws_lambda_function" "sqs-to-firehose" {
  function_name = "sqs-to-firehose"
 
  filename         = "../target/people.zip"
  source_code_hash = "${filebase64sha256("../target/people.zip")}"
  handler          = "people_linux_amd64"
  runtime          = "nodejs8.10"
  timeout          = "30"
  memory_size      = "256"
  role             = "${aws_iam_role.people_lambda_role.arn}"
}