# --------------------- VPC Block ---------------------
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = "${merge(var.default_tags, map(
        "Name" , "default-vpc"
    ))}"
}
# -----------------------------------------------------




# --------------------- Subnet Block ---------------------
resource "aws_subnet" "public-us-east-1a" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true

    tags = "${merge(var.default_tags, map(
        "Name" , "public-subnet-us-east-1a"
    ))}"
}


resource "aws_subnet" "private-us-east-1a" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.region}b"

    tags = "${merge(var.default_tags, map(
        "Name" , "private-subnet-us-east-1a"
    ))}"
}
# ------------------------------------------------------




# -------------- Internet Gateway Block -----------------
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

    tags = "${merge(var.default_tags, map(
        "Name" , "default-internet-gw"
    ))}"
}
# ------------------------------------------------------




# ------------------ NAT Gateway Block ---------------------
resource "aws_eip" "nat" {
    vpc = true
    depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "default" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id     = "${aws_subnet.public-us-east-1a.id}"

    tags = "${merge(var.default_tags, map(
        "Name" , "default-nat-gateway"
    ))}"

    depends_on = ["aws_internet_gateway.default"]
}
# ------------------------------------------------------


# --------------------- Route Table Block ---------------------

## Route Table for public subnet
resource "aws_route_table" "public-us-east-1a" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = "${merge(var.default_tags, map(
        "Name" , "route-table-public-subnet"
    ))}"
}

## Route Table for private subnet
resource "aws_route_table" "private-us-east-1a" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.default.id}"
    }

    tags = "${merge(var.default_tags, map(
        "Name" , "route-table-private-subnet"
    ))}"
}


### Route Table association
resource "aws_route_table_association" "public-us-east-1a" {
    subnet_id = "${aws_subnet.public-us-east-1a.id}"
    route_table_id = "${aws_route_table.public-us-east-1a.id}"
}

resource "aws_route_table_association" "private-us-east-1a" {
    subnet_id = "${aws_subnet.private-us-east-1a.id}"
    route_table_id = "${aws_route_table.private-us-east-1a.id}"
}
# ----------------------------------------------------------



