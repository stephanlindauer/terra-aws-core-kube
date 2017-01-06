resource "aws_iam_instance_profile" "worker_instance_profile" {
  name  = "worker_instance_profile"
  roles = ["iam_worker_role"]
}

resource "aws_iam_role" "iam_worker_role" {
  name = "iam_worker_role"

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

resource "aws_iam_role_policy" "iam_worker_role_policy" {
  name = "iam_worker_role_policy"
  role = "${aws_iam_role.iam_worker_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
    }
  ]
}

EOF
}
