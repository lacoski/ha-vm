# Script HA VM Openstack cho CentOS 7
--- 
## Yêu cầu gói
```
yum install fping -y
```

## Thêm cmd trong `zone/available`
> Xem file demo (zone/available)
Check chắc chắn script tắt compute 1 và compute 2 chạy được.

## Kịch bản
```bash
*/5 * * * * source /etc/ha-vm/admin-openrc.sh ; bash /etc/ha-vm/ha-vm.sh
```

## File môi trường
```bash
[root@controller ha-vm]# cat admin-openrc.sh 
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=Welcome123
export OS_AUTH_URL=http://172.16.4.11:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

## Chạy
- Đưa toàn bộ file trong thư mục vào /etc/ha-vm/
- Tạo kịch bản compute down trong <ha-vm>/zone/available/<tên compute> (VD: compute01)
- Add crontab như mẫu 