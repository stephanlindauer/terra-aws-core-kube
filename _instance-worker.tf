data "template_file" "k8s-worker" {
  template = "${file("assets/cloud-config/worker/cloud-config.yml")}"

  vars {
    ETCD_ENDPOINTS = "${join(",", formatlist("http://%s:%s", aws_instance.k8s-etcd.*.private_ip, "2379")  ) }"

    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"

    tls-root-ca     = "${file("assets/tls/ca.pem")}"
    tls-root-ca-key = "${file("assets/tls/ca-key.pem")}"
    tls-client-conf = "${file("assets/tls/api-client.cnf")}"

    MASTER_HOST = "${ aws_instance.k8s-master.private_ip }"
  }
}

resource "aws_launch_configuration" "worker" {
  image_id      = "${lookup(var.amis, var.region)}"
  instance_type = "t2.medium"
  key_name      = "${var.aws_key_name}"

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

  desired_capacity          = "2"
  health_check_grace_period = 60
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${ aws_launch_configuration.worker.name }"
  max_size                  = "5"
  min_size                  = "2"
  vpc_zone_identifier       = ["${aws_subnet.k8s-public.id}"]

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.worker.name}"
}

resource "aws_cloudwatch_metric_alarm" "bat" {
  alarm_name          = "terraform-test-foobar5"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.worker.name}"
  }

  alarm_description = "This metric monitor ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.bat.arn  }"]
}
