Membuat resources yang dibuat secara otomatis menggunakan Infrastructur as a Code (IaC) Terraform

🧩 Resources yang akan dibuat

    Amazon EC2 Instance – Menggunakan Ubuntu 22.04 LTS - ap-southeast-1.

    Amazon RDS – Menggunakan db.t3micro engine version = "8.0.35"

    VPC – Menggunakan vpc defaultnya AWS

    S3 Bucket – Digunakan untuk tempat penyimpanan file asset

    Security Group – Allow HTTP, HTTPS, SSH, MySQL
    Region - Menggunakan ap-southeast-1

🛠️ Langkah Step-by-Step Setup Terraform
✅ Diagram Arstiketurnya

image.png
✅ Step 1: Persiapan Install Terraform di WSL

    sudo apt update && sudo apt install -y software-properties-common gnupg curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com
    $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y terraform
    terraform -v

✅ Step 2: Mengatur Kredensial AWS

Terraform menggunakan salah satu dari cara berikut untuk mengakses akun AWS kamu:
(a) File ~/.aws/credentials (paling umum)

Gunakan AWS CLI (kalau kamu install) atau buat file ini secara manual:

mkdir -p ~/.aws

vi ~/.aws/credentials

[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

vi ~/.aws/config

[default]
region = ap-southeast-1

mkdir -p ~/.aws

vi ~/.aws/credentials

[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

vi ~/.aws/config
[default]
region = ap-southeast-1

    Kamu bisa dapatkan akses key dari: IAM > Users > Security credentials


✅ Step 3: Koneksi Internet

Karena Terraform akan:

    Menghubungi AWS API

    Mendownload provider plugin

Pastikan WSL kamu punya akses internet (cek ping google.com atau curl aws.amazon.com).
✅ Step 5: cara menjalankan terraform

# 0. clone porject dari github
git clone git@github.com:iniwidi/terraform.git && cd terraform

# 0. Inisialisasi Terraform
terraform init

# 1. Buat dan simpan plan
terraform plan -out=tfplan

# 2. Review isi plan (opsional)
terraform show tfplan

# 3. Apply plan yang sudah disimpan
terraform apply tfplan

 
✅ Step 6: Persiapan Terraform untuk menghapus/destroy

Untuk menghapus/destroy semua resources AWS yang telah dibuat melalui Terraform, Anda bisa menggunakan perintah berikut:
Cara Destroy Resources Terraform:

    Pertama, lihat dulu apa yang akan di-destroy (opsional tapi disarankan):
   
       terraform plan -destroy -out=tfdestroyplan

Ini akan menunjukkan semua resources yang akan dihapus.

Eksekusi destroy:

terraform destroy tfdestroyplan

Terraform akan menampilkan daftar resources yang akan dihapus dan meminta konfirmasi.

Jika ingin langsung destroy tanpa konfirmasi:

terraform destroy -auto-approve

Beberapa catatan penting:

    S3 Bucket:

        Karena Anda mengatur force_destroy = true, bucket akan dihapus meskipun berisi file

        Tanpa setting ini, destroy akan gagal jika bucket tidak kosong

    RDS Instance:

        Karena ada skip_final_snapshot = true, database akan dihapus tanpa backup terakhir

        Jika ini di-production, sebaiknya buat snapshot manual dulu

    Resources yang akan dihapus:

        EC2 Instance

        Security Group

        RDS MySQL Instance

        DB Subnet Group

        S3 Bucket

        Random ID resource

Jika mengalami error saat destroy:

    Resources manual:
    Pastikan tidak ada resources yang dibuat manual (di luar Terraform) yang bergantung pada resources yang dikelola Terraform

    Dependency error:
    Terkadang perlu menjalankan destroy beberapa kali jika ada dependency issues

    Force destroy:
    Untuk kasus tertentu bisa tambahkan flag -force, tapi hati-hati:
  
    terraform destroy -force

Best Practice Destroy:

    Backup data penting dulu jika ada

    Verifikasi environment yang akan di-destroy sudah benar

    Gunakan workspace jika ingin memisahkan environment (dev/staging/prod)

    Set timeout jika resources besar:
 
    terraform destroy -timeout=30m

Setelah destroy selesai, Anda bisa verifikasi di AWS Console bahwa semua resources sudah terhapus. Terraform juga akan menghapus file status (terraform.tfstate) yang menyimpan informasi tentang infrastruktur yang dikelola.