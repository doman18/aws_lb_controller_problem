# https://www.youtube.com/watch?v=Gj31ffZm-ag

########################################  IAM Role & Policy   ###################################### 

data "aws_iam_policy_document" "eks_ebs_csi_driver_policy_doc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi_driver_policy_doc.json
  name               = "aws-ebs-csi-driver-role"
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_driver_policy_attach" {
  role       = aws_iam_role.eks_ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

########################################  EBS addon   ###################################### 

resource "aws_eks_addon" "ebs_csi_driver" {
    cluster_name = aws_eks_cluster.cluster.name
    addon_name = "aws-ebs-csi-driver"
    # aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
    addon_version = "v1.11.4-eksbuild.1"
    service_account_role_arn = aws_iam_role.eks_ebs_csi_driver_role.arn
}

