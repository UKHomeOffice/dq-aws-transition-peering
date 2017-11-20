/*********************************
* Setup VPC Peering
**********************************/

/**
 * Intra AWS account VPC peering connections.
 *
 * Establishes a relationship resource between the "project1" and "project2" VPC.
 * Establishes a relationship resource between the "project1" and "project3" VPC.
 * Establishes a relationship resource between the "project3" and "project2" VPC.
 * Establishes a relationship resource between the "project4" and "project1" VPC.
 * Establishes a relationship resource between the "project4" and "project2" VPC.
 * Establishes a relationship resource between the "project4" and "project3" VPC.
 */
 resource "aws_vpc_peering_connection" "project12project2" {
   vpc_id = "${aws_vpc.project1.id}"
   peer_vpc_id = "${aws_vpc.project2.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project1 and project2"
   }
 }

 resource "aws_vpc_peering_connection" "project12project3" {
   vpc_id = "${aws_vpc.project1.id}"
   peer_vpc_id = "${aws_vpc.project3.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project1 and project3"
   }
 }

 resource "aws_vpc_peering_connection" "project32project2" {
   vpc_id = "${aws_vpc.project3.id}"
   peer_vpc_id = "${aws_vpc.project2.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project3 and project2"
   }
 }

 resource "aws_vpc_peering_connection" "project42project2" {
   vpc_id = "${aws_vpc.project4.id}"
   peer_vpc_id = "${aws_vpc.project2.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project4 and project2"
   }
 }

 resource "aws_vpc_peering_connection" "project42project1" {
   vpc_id = "${aws_vpc.project4.id}"
   peer_vpc_id = "${aws_vpc.project1.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project4 and project1"
   }
 }

 resource "aws_vpc_peering_connection" "project42project3" {
   vpc_id = "${aws_vpc.project4.id}"
   peer_vpc_id = "${aws_vpc.project3.id}"
   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
   auto_accept = true
   tags {
     Name = "project4 and project3"
   }
 }

 /**
  * Inter AWS account VPC peering connections.
  *
  * Establishes a relationship resource between the "project4" and "external1" VPC.
  */

  # Requester's side of the connection.
  resource "aws_vpc_peering_connection" "project42external1" {
    vpc_id        = "${aws_vpc.project4.id}"
    peer_vpc_id   = "${var.external1_vpc_id}"
    peer_owner_id = "${var.external1_vpc_owner_id}"
    auto_accept   = false

    tags {
      Side = "Requester"
    }
    tags {
      Name = "project4 to External1"
    }
  }

  # Accepter's side of the connection.
  resource "aws_vpc_peering_connection_accepter" "external12project4" {
    provider                  = "aws.peer"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.project42external1.id}"
    auto_accept               = true

    tags {
      Side = "Accepter"
    }
    tags {
      Name = "External1 to project4"
    }
  }


/*********************************
* Setup routing between VPC CIDR blocks
**********************************/

/**
 * Route rule.
 *
 * Creates a new route rule on the "project1" VPC main route table. All requests
 * to the "project2" "project3" "project4" VPC's IP range will be directed to the respective VPC peering
 * connection.
 */

resource "aws_route" "project12project2" {
  route_table_id = "${aws_vpc.project1.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.project2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.project12project2.id}"
}

resource "aws_route" "project12project3" {
  route_table_id = "${aws_vpc.project1.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.project3.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.project12project3.id}"
}

resource "aws_route" "project12project4" {
 route_table_id = "${aws_vpc.project1.main_route_table_id}"
 destination_cidr_block = "${aws_vpc.project4.cidr_block}"
 vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project1.id}"
}

/**
 * Route rule.
 * Creates a new route rule on the "project2" VPC main route table. All
 * requests to the "project1" "project3" "project4" VPC's IP range will be directed to the VPC
 * peering connection.
 */

resource "aws_route" "project22project1" {
  route_table_id = "${aws_vpc.project2.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.project1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.project12project2.id}"
}

resource "aws_route" "project22project3" {
  route_table_id = "${aws_vpc.project2.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.project3.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.project32project2.id}"
}

resource "aws_route" "project22project4" {
 route_table_id = "${aws_vpc.project2.main_route_table_id}"
 destination_cidr_block = "${aws_vpc.project4.cidr_block}"
 vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project2.id}"
}

/**
 * Route rule.
 * Creates a new route rule on the "project3" VPC main route table. All
 * requests to the "project1" "project2" "project4" VPC's IP range will be directed to the VPC
 * peering connection.
 */
 resource "aws_route" "project32project1" {
   route_table_id = "${aws_vpc.project3.main_route_table_id}"
   destination_cidr_block = "${aws_vpc.project1.cidr_block}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.project12project3.id}"
 }

 resource "aws_route" "project32project2" {
   route_table_id = "${aws_vpc.project3.main_route_table_id}"
   destination_cidr_block = "${aws_vpc.project2.cidr_block}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.project32project2.id}"
 }

 resource "aws_route" "project32project4" {
  route_table_id = "${aws_vpc.project3.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.project4.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project3.id}"
 }

 /**
  * Route rule.
  * Creates a new route rule on the "project4" VPC main route table. All
  * requests to the "project1" "project2" "project3" "external1" VPC's IP range will be directed to the VPC
  * peering connection.
  */

  resource "aws_route" "project42project1" {
    route_table_id = "${aws_vpc.project4.main_route_table_id}"
    destination_cidr_block = "${aws_vpc.project1.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project1.id}"
  }

  resource "aws_route" "project42project2" {
    route_table_id = "${aws_vpc.project4.main_route_table_id}"
    destination_cidr_block = "${aws_vpc.project2.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project2.id}"
  }

  resource "aws_route" "project42project3" {
   route_table_id = "${aws_vpc.project4.main_route_table_id}"
   destination_cidr_block = "${aws_vpc.project3.cidr_block}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.project42project3.id}"
  }

  resource "aws_route" "project42external1" {
   route_table_id = "${aws_vpc.project4.main_route_table_id}"
   destination_cidr_block = "${var.aws_peer_cidr}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.project42external1.id}"
  }
