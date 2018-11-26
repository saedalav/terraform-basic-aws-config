# -------------- Security Group for Basion Host -------------
resource "aws_security_group" "bastion-sg" {
    name = "ssh-from-everywhere"
    description = "Allows connection to public subnet via port 22. To be used with a Bastion Host"
    vpc_id = "${aws_vpc.default.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
  
    tags = "${merge(var.default_tags, map(
        "Name" , "ssh-sg"
    ))}"
}
# --------------------------------------------------------



# -------------- Bastion Host  -------------------------
resource "aws_key_pair" "bastion-access" {
    key_name = "${var.bastion_key_name}"
    public_key = "${file("resources/key.pub")}"
}



resource "aws_instance" "bastion" {
    ami           = "${var.bastion_host_ami}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public-us-east-1a.id}"
    vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
    key_name = "${aws_key_pair.bastion-access.key_name}"

    tags = "${merge(var.default_tags, map(
        "Name" , "Basion Host"
    ))}"
}


output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
# -----------------------------------------------------
