# AWS Provider information
provider "aws" {
    region = "${var.region}"
    shared_credentials_file = "/usr_share/.aws/credentials"
}

resource "aws_security_group" "puppet-security-group" {
    name = "puppet-security-group"
    description = "Security Group for PuppetMaster and PuppetAgent"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = "${element(var.ports, 1)}"
        to_port = "${element(var.ports, 1)}"
        protocol = "tcp"
        cidr_blocks = ["${var.cidr_block_all_traffic}"]
    }

    ingress {
        from_port = "${element(var.ports, 0)}"
        to_port = "${element(var.ports, 0)}"
        protocol = "tcp"
        cidr_blocks = ["${var.cidr_block_all_traffic}"]
    }

    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["${var.cidr_block_all_traffic}"]
    }

    egress {
        from_port = "${element(var.ports, 2)}"
        to_port = "${element(var.ports, 2)}"
        protocol = "-1"
        cidr_blocks = ["${var.cidr_block_all_traffic}"]
    }
    tags = {
        Name = "Puppet-SG"
        description = "Security Group for PuppetServer and Client"
    }
}

# Creating EC2 Instance for Puppet Master and Agent

resource "aws_key_pair" "puppet_ec2_key" {
    key_name   = "${var.key_pair_name}"
    public_key = "${file("puppet_ec2_key.pub")}"
}


resource "aws_instance" "PuppetServer" {
    ami = "${lookup(var.ami, var.region)}"
    instance_type = "${var.instance_type}"
    subnet_id = "${var.subnet_id}"
    vpc_security_group_ids = ["${aws_security_group.puppet-security-group.id}"]
    count = "${length(var.tags)}"
    associate_public_ip_address = "true"
    key_name = "${var.key_pair_name}"
    tags = {
        Name = "Puppet${element(var.tags, count.index)}"
        Env = "DEV"
    }
}
