data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y
              dnf install -y nodejs

              mkdir -p /opt/aws-web-app

              cat > /opt/aws-web-app/server.js <<'EOT'
              const http = require("http");

              const server = http.createServer((req, res) => {
                  res.writeHead(200, {"Content-Type": "text/html"});

                  res.end(`
                      <h1>AWS Web Architecture</h1>
                      <p>Node.js application is running successfully.</p>
                      <p>Server: EC2</p>
                  `);
              });

              server.listen(3000, "0.0.0.0", () => {
                  console.log("Application running on port 3000");
              });
              EOT

              cd /opt/aws-web-app
              node server.js > /var/log/aws-web-app.log 2>&1 &
              EOF

  tags = {
    Name = "${var.project_name}-app"
  }
}