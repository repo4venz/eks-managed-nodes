output "fluentbit_role_arn" {
  value = aws_iam_role.fluentbit_role.arn
}

/*
output "fluentbit_cloudwatch_log_path" {
  value = aws_cloudwatch_log_group.fluentbit.name
}
*/