resource "aws_iam_instance_profile" "master_instance_profile" {
  name  = "master_instance_profile"
  roles = ["iam_master_role"]
}

resource "aws_iam_role" "iam_master_role" {
  name = "iam_master_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_master_role_policy" {
  name = "iam_master_role_policy"
  role = "${aws_iam_role.iam_master_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}
