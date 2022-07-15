# terraform-aws01

export TF_VAR_access_key= enteryourkey

export TF_VAR_secret_key= enteryourkey

```
terraform init  // command is used to initialize a working directory containing Terraform configuration files. first time only
terraform plan  // verified code
terraform plan -parallelism=m /// m = 2 tang toc do plan
$ terraform plan -out plan.out
$ terraform show -json plan.out > plan.json   // luu ket qua plan

```

 terraform plan -out plan.out
 terraform apply "plan.out"   /// chay lenh apply voi ket qua da luu o tren 


terraform apply // play code
- terraform.tfsate ---> sinh ra khi chay apply ---> show nhung resource duoc tao

terraform destroy  // delete code
- terraform.tfsate ---> sinh ra khi chay apply ---> show nhung resource duoc tao  ---> check noi dung 2 file khac nhau khi apply & destroy

Data block:

terraform có cung cấp cho ta một block khác dùng để queries và tìm kiếm data trên AWS, block này sẽ giúp ta tạo resource một cách linh hoạt hơn là phải điền cứng giá trị của resource. Ví dụ như ở trên thì trường ami của EC2 ta fix giá trị là ami-09dd2e08d601bff67, để biết được giá trị này thì ta phải lên AWS để kiếm, với lại nếu ta dùng giá trị này thì người khác đọc cũng không biết được giá trị này là thuộc ami loại gì.

example: https://github.com/huannv93/terraform-aws02/blob/main/EC2create.tf
---> khi chay terraform plan van show duoc gia tri get dc tu api aws : 

Terraform will perform the following actions:

  # aws_instance.hello will be created
  + resource "aws_instance" "hello" {
      + ami                                  = "ami-0892d3c7ee96c0bf7"
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Life cycle : Vong doi cua terraform: 


![image](https://user-images.githubusercontent.com/64687828/178397719-b588f8cd-4a57-4f65-9851-22d0e13894ab.png)


Create() sẽ được gọi trong quá trình tạo resource, Read() được gọi trong quá trình plan, Update() được gọi trong quá trình cập nhật resource, và Delete() được gọi trong quá trình xóa resource.



-- force approve for terraform : terraform destroy **-auto-approve**
**
Resource drift**
Resource drift là vấn đề khi config resource của ta bị thay đổi bên ngoài terraform, với AWS thì có thể là do ai đó dùng Web Console của AWS để thay đổi config gì đó của resource mà được ta deploy bằng terraform.
Thì khi ta sửa như vậy, thì terraform không có tự động phát hiện và update lại file config terraform của ta nhé, nó không có thần kì như vậy 😂. Mà khi ta chạy câu lệnh apply, nó sẽ phát hiện thay đổi và update lại trường tags mà ta thay đổi ngoài terraform thành giống với tags ta viết trong file config. Bạn chạy câu lệnh plan trước để xem.

Note: Objects have changed outside of Terraform

Và tùy thuộc vào thuộc tính mà ta thay đổi bên ngoài terraform là force new hay normal update thì terraform sẽ thực hiện re-create hay update bình thường cho ta.

Vậy còn nếu ta có một resource đang chạy rất nhiều thứ quan trọng, như là database chẳng hạng, thì khi ta thay đổi một thuộc tính là force new thì DB của ta sẽ bị xóa đi và tạo lại cái mới hay sao? Làm sao ta chấp nhận việc đó được? Để giải quyết vấn đề này thì mình sẽ viết một bài khác để giải thích nhé, tại làm hơi dài

Link research: https://viblo.asia/p/terraform-series-bai-2-life-cycle-cua-mot-resource-trong-terraform-RnB5pOMDlPG



3! **Terraform Series - Bài 3 - Terraform functional programming**

variable.tf
```
variable "instance_type" {
  type = string
  description = "Instance type of the EC2"
}
```
- type kiểu dữ liệu  : string la ky tu vd hello world.... ngoai ra con co cac type khac Basic type: string, number, bool ,,,, Complex type: list(), set(), map(), object(), tuple()

Trong terraform, type number và type bool sẽ được convert thành type string khi cần thiết. Nghĩa là 1 sẽ thành "1", true sẽ thành "true"

- Gán giá trị cho bien variable 
variable.tfvars
instance_type = "t2.micro"

Khi chay apply , default se lay file variable.tfvars de dien gia tri bien , neu muon defiend rieng tung tfvaf thi dung nhu sau
```terraform apply -var-file="production.tfvars" ```
---> production.tfvvars dang duoc chon
+ Validating variables
điều khiện với variables :
```
variable "instance_type" {
  type = string
  description = "Instance type of the EC2"

  validation {
    condition = contains(["t2.micro", "t3.small"], var.instance_type)
    error_message = "Value not allow."
  }
}
```

- **Output**
```
...

output "ec2" {
  value = {
    public_ip = aws_instance.hello.public_ip
  }
}
```


- **Count parameter**
---> muc dich: vi du can tao 1000 EC2 cung luc
```
provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "hello" {
  count         = 5
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

output "ec2" {
  value = {
    public_ip1 = aws_instance.hello[0].public_ip
    public_ip2 = aws_instance.hello[1].public_ip
    public_ip3 = aws_instance.hello[2].public_ip
    public_ip4 = aws_instance.hello[3].public_ip
    public_ip5 = aws_instance.hello[4].public_ip
  }
}
```

- **For expressions**
For cho phép ta duyệt qua một list, cú pháp của lệnh for như sau:

Ta sẽ dùng for để rút gọn phần output IP của EC2. Cập nhật lại file main.tf
```
...

resource "aws_instance" "hello" {
  count         = 5
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

output "ec2" {
  value = {
    public_ip = [ for v in aws_instance.hello : v.public_ip ]
  }
}
```
- **Format function**
Hàm format sẽ giúp ta nối chuỗi theo dạng ta muốn, cập nhật output lại như sau:

```
...

resource "aws_instance" "hello" {
  count         = 5
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

output "ec2" {
  value = { for i, v in aws_instance.hello : format("public_ip%d", i + 1) => v.public_ip }
}
```



- **File function**
File function sẽ giúp ta tải nội dung của một file nào đó vào bên trong config file của terraform

- **Fileset function**
```{
  "index.html": "index.html",
  "index.css" : "index.css"
}
```
- **Local values**
Không giống như variable block, ta cần khai báo type, thì locals block ta sẽ gán thẳng giá trị cho nó. Ví dụ như sau:
```
locals {
  one = 1
  two = 2
  name = "max"
  flag = true
}
```

Tong ket bai 3: 
Vậy là ta đã tìm hiểu xong về một số cách đơn giản để lập trình được trong terraform. Sử dụng varibale để chứa biến, sử dụng output để show giá trị ra terminal, sử dụng for để duyệt qua mảng, sử dụng locals để lưu giá trị và sử dụng lại nhiều lần. Nếu có thắc mắc hoặc cần giải thích rõ thêm chỗ nào thì các bạn có thể hỏi dưới phần comment. Hẹn gặp các bạn ở bài tiếp theo.

Link : https://viblo.asia/p/terraform-series-bai-3-terraform-functional-programming-4P856GnWKY3


--**Bai4:  Terraform Series - Bài 4 - Terraform Module: Create Virtual Private Cloud on AWS**  ----

- **Provisioning Virtual Private Cloud**
```
provider "aws" {
  region  = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "custom"
  }
}

locals {
  private = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  zone    = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private[count.index]
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public[count.index]
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
```

```
terraform apply -auto-approve

terraform destroy -auto-approve

```

![image](https://user-images.githubusercontent.com/64687828/178700081-ae0b1976-1aff-4c1b-a36a-2a4267dceec1.png)

- **Terraform Module**
Một module cơ bản sẽ gồm 3 file sau đây:
.
├── main.tf
└── vpc
    ├── main.tf
    ├── outputs.tf
    └── variables.tf


main.tf chứa code.
variables.tf chứa input vào của module.
outputs.tf chưa giá trị đầu ra của module.

Ngoài ra còn một vài file khác mà không bắt buộc là providers.tf, versions.tf
// thuong se co file variables.tfvar de truyen gia tri theo tung product ( dev, staging, production...)  ./dev/dev.tfvar , ./product/p1.tfvar


main.tf of 1 module:
```
module <module_name> {
  source = <source>
  version = <version>

  input_one = <input_one>
  input_two = <input_two>
}
```

./main.tf
```
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "./vpc"

  vpc_cidr_block    = "10.0.0.0/16"
  private_subnet    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
```

./vpc/main.tf 

```
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name" = "custom"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
```

./vpc/variables.tf

```
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type    = list(string)
}

variable "public_subnet" {
  type    = list(string)
}

variable "availability_zone" {
  type    = list(string)
}
```



-   **Common module**
Ở trên ta viết với mục đích là tìm hiểu, khi làm thực tế cho môi trường production, ta nên xài những module có sẵn trên mạng, họ viết sẽ kĩ hơn nhiều và sẽ có rất nhiều chức năng và use case hơn so với ta phải tự viết. Ví dụ vpc module ở trên, ta có thể sử dụng một module có sẵn là terraform-aws-modules/vpc/aws.
HASCICOP has document for create AWS: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

- Tong ket bai 4: 
Vậy là ta đã tìm hiểu xong cách viết code từ đầu và sau đó tổ chức code lại thành module, cách publish một module lên trên mạng, cách sử dụng module có sẵn. Module giúp ta sử dụng code có sẵn và tránh phải viết code đi code lại nhiều lần. Nếu có thắc mắc hoặc cần giải thích rõ thêm chỗ nào thì các bạn có thể hỏi dưới phần comment. Hẹn gặp mọi người ở bài tiếp theo. Bài tiếp theo ta cũng nói tiếp về module mà sẽ đi sâu hơn chút, ta sẽ làm ví dụ tạo VPC, Autoscaling Group và Load Balancer trên AWS.

- https://viblo.asia/p/terraform-series-bai-4-terraform-module-create-virtual-private-cloud-on-aws-ORNZqp2MK0n

--**Bai5:  Terraform Series - Module In Depth: Create Multi-Tier Application**  ----

 Ở bài này chúng ta sẽ tìm hiểu sâu hơn về module thông qua việc xây dựng hạ tầng cho một ứng dụng Multi-Tier bao gồm AWS Application Load Balancer + Auto Scaling Group + Relational Database Service
 
 ![image](https://user-images.githubusercontent.com/64687828/179139809-795677ec-e050-49d1-8b93-d65400d40f83.png)








