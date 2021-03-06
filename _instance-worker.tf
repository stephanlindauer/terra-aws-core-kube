data "template_file" "k8s-worker" {
  template = "${file("assets/cloud-config/worker/cloud-config.yml")}"

  vars {
    ETCD_ENDPOINTS = "${join(",", formatlist("http://%s:%s", aws_instance.k8s-etcd.*.private_ip, "2379")  ) }"

    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"

    tls-root-ca     = "${file("assets/tls/ca.pem")}"
    tls-root-ca-key = "${file("assets/tls/ca-key.pem")}"
    tls-client-conf = "${file("assets/tls/api-client.cnf")}"

    MASTER_HOST = "${ aws_instance.k8s-master.private_ip }"

    node_label = "worker"
  }
}

resource "aws_launch_configuration" "worker" {
  image_id             = "${lookup(var.amis, var.region)}"
  instance_type        = "t2.medium"
  key_name             = "${var.aws_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.worker_instance_profile.id}"

  /*TODO*/
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
  }

  security_groups = [
    "${aws_security_group.k8s-worker.id}",
  ]

  user_data = "${ data.template_file.k8s-worker.rendered }"
}

resource "aws_autoscaling_group" "worker" {
  name = "k8s-aws_autoscaling_group"

  desired_capacity          = "1"
  health_check_grace_period = 60
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${ aws_launch_configuration.worker.name }"
  max_size                  = "8"
  min_size                  = "1"
  vpc_zone_identifier       = ["${aws_subnet.k8s-public.id}"]

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.worker.name}"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.worker.name}"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high_cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "50"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = "2"
  period              = "60"
  alarm_actions       = ["${aws_autoscaling_policy.scale_up.arn  }"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.worker.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low_cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "20"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = "2"
  period              = "60"
  alarm_actions       = ["${aws_autoscaling_policy.scale_down.arn  }"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.worker.name}"
  }
}
