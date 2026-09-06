# 🌲 Andalan Tools

> **Aplikasi utilitas dokumen & gambar all-in-one yang 100% offline, privat, dan cepat untuk iOS.**  
> Dibangun dengan Flutter, mengusung estetika minimalis palet **Everforest**, animasi pegas native iOS, dan proteksi biometrik Face ID.

---

## 💡 Cerita & Latar Belakang

### Kebutuhan Sederhana yang Menjadi Rumit
Hampir setiap minggu, kita berurusan dengan tugas-tugas dokumen digital yang sepele:
- Menggabungkan dua atau tiga file PDF formulir/surat pernyataan menjadi satu berkas.
- Memindai beberapa lembar dokumen fisik atau nota belanja dari kamera menjadi file PDF yang rapi.
- Mengecilkan ukuran PDF agar muat dilampirkan ke email instansi atau portal lamaran kerja.
- Menghapus informasi sensitif seperti titik koordinat GPS rumah (*EXIF metadata*) pada foto KTP/SIM sebelum dikirim ke pihak lain.
- Mengonversi naskah Word (`.docx`) menjadi PDF saat sedang *on the go* di jalan.

### Realitas Ekosistem Mobile Saat Ini
Ketika kita membuka App Store dan mencari kata kunci *"merge PDF"*, *"scan document"*, atau *"convert image"*, apa yang kita temukan?

1. **Jebakan Langganan Mahal (*Subscription Traps*)**:  
   Banyak aplikasi utilitas dasar meminta langganan mingguan yang tidak masuk akal—ada yang mematok Rp79.000/minggu atau ratusan ribu per tahun hanya untuk sekadar membalik urutan halaman PDF.
2. **Eksploitasi Privasi Dokumen (*Cloud Upload Risks*)**:  
   Mayoritas aplikasi gratisan ternyata mengirimkan berkas pengguna ke server antah-berantah di cloud untuk diproses. Padahal berkas yang diproses seringkali memuat data sangat rahasia: salinan KTP, KK, nomor rekening, paspor, kontrak kerja, hingga riwayat medis.
3. **Antarmuka Penuh Iklan & Norak**:  
   Penuh dengan banner video yang tidak bisa di-skip, pop-up meminta review bintang lima, tombol *"PRO"* palsu berkedip-kedip, dan palet warna neon gradien yang melelahkan mata.

### Lahirnya Andalan Tools
Sebagai pengguna harian sistem operasi Linux (CachyOS/Arch) yang sehari-hari menggunakan iPhone tanpa memiliki perangkat Mac, pembuat merasa lelah harus terus berkompromi dengan aplikasi pihak ketiga yang tidak menghargai privasi dan estetika.

**Andalan Tools** diciptakan sebagai jawaban:
- **100% Pemrosesan di Perangkat (*Local-First*)**: Tidak ada data yang meninggalkan ponsel Anda. Tidak ada server perantara, tidak ada analitik pihak ketiga, tidak ada pelacakan.
- **Gratis & Open Source Selamanya**: Tanpa langganan, tanpa iklan, tanpa watermark paksaan.
- **Estetika Tenang & Modern**: Dirancang dengan prinsip desain *Swiss Typography* dan palet warna organik **Everforest** (*Warm Canvas, Deep Evergreen, Muted Sage*), lengkap dengan fisika pegas iOS (*spring physics*) dan umpan balik getaran haptik (*haptic feedback*).

---

## ✨ Fitur Utama

Aplikasi ini menyatukan 7 alat pengolahan dokumen utama ditambah brankas lokal berkeamanan tinggi:

| Fitur | Deskripsi |
| :--- | :--- |
| 📸 **Image to PDF** | Scan dokumen dari kamera atau galeri foto, lakukan pemotongan (*crop*) presisi, dan susun beberapa foto menjadi satu dokumen PDF berkualitas tinggi. |
| 📑 **PDF Merger** | Gabungkan banyak file PDF terpisah menjadi satu dokumen urut dengan antarmuka visual *drag-and-drop*. |
| 🔐 **Kunci & Proteksi PDF** | Enkripsi dokumen PDF menggunakan standar industri **AES-256 bit** dengan kata sandi langsung di perangkat. |
| 🗜️ **Kompresi PDF & Pembersih EXIF** | Pangkas ukuran file PDF untuk menghemat kuota/email, serta bersihkan metadata lokasi GPS dan tipe kamera dari foto dokumen sensitif sebelum dibagikan. |
| 📝 **PDF Editor & OCR** | Lihat isi PDF, ekstrak teks secara lokal (*optical character recognition*), atur tata letak, atau hapus halaman yang tidak dibutuhkan. |
| 🔄 **Konversi Format Gambar** | Konversi instan bolak-balik antara format populer: PNG, JPG, WebP, dan HEIC. |
| 📄 **Docx to PDF** | Konversi dokumen Microsoft Word (`.docx`) menjadi PDF lengkap dengan deteksi tabel dan gambar secara offline. |
| 🛡️ **Brankas & Riwayat Dokumen** | Simpan dokumen hasil olahan di penyimpanan lokal privat yang terlindungi oleh autentikasi biometrik **Face ID / Touch ID / Passcode**. |

---

## 🎨 Filosofi Desain: Everforest & Swiss Minimalism

- **Palet Warna Organik**: Menghindari hitam-putih kontras tajam maupun warna neon mencolok. Menggunakan palet Everforest (`#FAF9F5` latar kanvas lembut, `#232A2E` teks grafit pekat, `#7A8478` abu sage, dan `#2D4B3E` aksen daun pinus).
- **Lambang Dokumen Presisi**: Logo aplikasi digambar secara geometris (*CustomPainter*) membentuk dua lembaran dokumen bertingkat dengan potongan sudut diagonal optik (*chamfer notch*).
- **Sentuhan Interaktif Asli iOS**: Setiap kartu dan tombol memiliki respons mikroskala elastis saat disentuh (`IosBouncyCard`) disertai getaran halus haptik perangkat.

---

## 🚀 Instalasi & Sideloading (Singkat & On-Point)

Karena aplikasi ini didistribusikan secara independen tanpa biaya Apple Developer Program berbayar, Anda dapat memasangnya ke iPhone dalam hitungan menit:

### Metode 1: Pasang Berkas `.ipa` Siap Pakai (Rekomendasi)
1. Unduh berkas `AndalanTools.ipa` dari tab **Releases** repositori ini (atau dari folder `build/ios_artifacts/AndalanTools-ipa/`).
2. Sideload berkas tersebut ke iPhone Anda menggunakan salah satu alat favorit berikut:
   - **[SideStore](https://sidestore.io/)**: Paling direkomendasikan—bisa me-refresh sertifikat otomatis via WiFi/VPN tanpa perlu colok kabel ke komputer lagi.
   - **[AltStore](https://altstore.io/)** / **[Sideloadly](https://sideloadly.io/)**: Melalui komputer Windows/macOS/Linux.
   - **[TrollStore](https://github.com/opa334/TrollStore)**: Untuk perangkat iOS yang kompatibel (instal permanen tanpa masa kedaluwarsa 7 hari).

### Metode 2: Kompilasi Sendiri dari Source Code
Pastikan Flutter SDK (>= 3.24) telah terpasang:

```bash
# 1. Clone repositori
git clone https://github.com/DarulQutni-Q/AndalanTools.git
cd AndalanTools

# 2. Ambil dependensi
flutter pub get

# 3. Build iOS unsigned IPA
flutter build ios --release --no-codesign
```

*Catatan: Repositori ini juga sudah dilengkapi dengan workflow otomatis **GitHub Actions** (`.github/workflows/ios-build.yml`). Setiap kali Anda melakukan `git push` ke branch `main`, GitHub Actions di server macOS akan otomatis mengompilasi berkas IPA baru.*

---

## 📂 Struktur Repositori

```text
lib/
├── core/
│   ├── theme/          # Palet warna Everforest dan tema aplikasi
│   ├── utils/          # Pengolah gambar, manajemen berkas lokal, generator PDF
│   └── widgets/        # Komponen UI iOS (AndalanLogo, IosHeaderVaultPill, IosBouncyCard)
├── features/
│   ├── compress_and_clean/ # Layanan & antarmuka kompresi PDF dan pembersih EXIF
│   ├── docx_converter/     # Ekstraksi naskah Word docx ke format PDF
│   ├── home/               # Beranda 7 alat dokumen dan akses Brankas
│   ├── image_converter/    # Konverter multi-format gambar (HEIC, PNG, JPG, WebP)
│   ├── image_to_pdf/       # Pemindai kamera, crop, dan penyusun PDF
│   ├── pdf_editor/         # Penampil PDF, ekstraksi teks OCR, dan pengelola halaman
│   ├── pdf_lock/           # Enkripsi dokumen PDF dengan sandi AES-256
│   ├── pdf_merger/         # Penggabung multi-dokumen PDF
│   └── vault/              # Penyimpanan brankas offline dengan proteksi Face ID
└── main.dart
```

---

## 🔒 Privasi & Keamanan

- **Zero Telemetry**: Tidak ada SDK analitik pihak ketiga (Google Firebase, Facebook SDK, Mixpanel, dll).
- **Zero Networking**: Aplikasi tidak pernah meminta akses jaringan internet untuk memproses berkas.
- **Zero Storage Leak**: Berkas temporer yang dibuat selama proses konversi langsung dibersihkan secara otomatis.
- **Hardware-backed Auth**: Proteksi brankas memanfaatkan API biometrik resmi iOS (`LocalAuthentication` / Secure Enclave).

---

## 📄 Lisensi

Proyek ini dirilis di bawah lisensi terbuka [MIT License](LICENSE). Bebas digunakan, dipelajari, dan dikembangkan kembali.
