# -------------- Security Group for Basion Host -------------
resource "aws_security_group" "private-ssh" {
    name = "ssh-from-bastion"
    description = "Allows connection to public subnet via port 22. To be used with a Bastion Host"
    vpc_id = "${aws_vpc.default.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = ["${aws_security_group.bastion-sg.id}"]
    }

    ingress {
        from_port   = 8
        to_port     = 0
        protocol    = "icmp"
        security_groups = ["${aws_security_group.bastion-sg.id}"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
  
    tags = "${merge(var.default_tags, map(
        "Name" , "ssh-from-bastion-only-sg"
    ))}"
}
# --------------------------------------------------------


# --------------------------------------------------------
resource "aws_key_pair" "private-key" {
    key_name = "private-key"
    public_key = "${file("resources/private.pub")}"
}
# --------------------------------------------------------




resource "aws_instance" "private-instance" {
    ami           = "${var.bastion_host_ami}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private-us-east-1a.id}"
    vpc_security_group_ids = ["${aws_security_group.private-ssh.id}"]
    key_name = "${aws_key_pair.private-key.key_name}"

    tags = "${merge(var.default_tags, map(
        "Name" , "Private Instance"
    ))}"
}

output "private_instance_ip" {
  value = "${aws_instance.private-instance.private_ip}"
}