########################################    SUBNETS   ###################################### 
resource "aws_subnet" "private_sub_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "${var.region}a"

  tags = {
    "Name"                                      = "${var.projname_short}-private-${var.region}a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.projname_short}-cluster" = "owned"
  }
}

resource "aws_subnet" "private_sub_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "${var.region}b"

  tags = {
    "Name"                                      = "${var.projname_short}-private-${var.region}b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster${var.projname_short}-cluster" = "owned"
  }
}

resource "aws_subnet" "public_sub_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "${var.projname_short}-public-${var.region}a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.projname_short}-cluster" = "owned"
  }
}

resource "aws_subnet" "public_sub_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "${var.projname_short}-public-${var.region}b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.projname_short}-cluster" = "owned"
  }
}

########################################    GATEWAYS   ###################################### 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.projname_short}-igw"
  }
}

# NAT
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.projname_short}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_sub_a.id

  tags = {
    Name = "${var.projname_short}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

########################################    ROUTES   ###################################### 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.projname_short}-private-route"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.projname_short}-public-route"
  }
}

resource "aws_route_table_association" "private_sub_a" {
  subnet_id      = aws_subnet.private_sub_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_sub_b" {
  subnet_id      = aws_subnet.private_sub_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_sub_a" {
  subnet_id      = aws_subnet.public_sub_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_sub_b" {
  subnet_id      = aws_subnet.public_sub_b.id
  route_table_id = aws_route_table.public.id
}

########################################  OUTPUTS   ###################################### 

output "region" {
  value       = var.region
}