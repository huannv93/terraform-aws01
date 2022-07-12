# terraform-aws01

export TF_VAR_access_key= enteryourkey

export TF_VAR_secret_key= enteryourkey

```
terraform init  // command is used to initialize a working directory containing Terraform configuration files. first time only
terraform plan  // verified code
terraform plan -parallelism=m /// m = 2 tang toc do plan
$ terraform plan -out plan.out
$ terraform show -json plan.out > plan.json   // luu ket qua plan


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

```
